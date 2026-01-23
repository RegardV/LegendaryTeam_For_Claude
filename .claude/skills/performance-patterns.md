# ⚡ Performance Patterns

## Purpose
Performance optimization patterns, caching strategies, database optimization, and monitoring best practices for building fast, scalable applications.

---

## Performance Principles

### 1. **Measure First, Optimize Later**
Don't guess where bottlenecks are - measure them.

```typescript
// Add performance timing
console.time('expensive-operation');
const result = await expensiveOperation();
console.timeEnd('expensive-operation');
// Output: expensive-operation: 1234.567ms

// Or use performance API
const start = performance.now();
await expensiveOperation();
const duration = performance.now() - start;
logger.info('Operation completed', { duration });
```

### 2. **Optimize for the Common Case**
Focus on the hot path - the code that runs most frequently.

### 3. **Avoid Premature Optimization**
"Premature optimization is the root of all evil" - Donald Knuth

Write clear code first, then optimize bottlenecks identified by profiling.

---

## Caching Strategies

### 1. **In-Memory Caching**
```typescript
class CacheService {
  private cache = new Map<string, { value: any; expiry: number }>();

  set(key: string, value: any, ttlMs: number) {
    this.cache.set(key, {
      value,
      expiry: Date.now() + ttlMs
    });
  }

  get(key: string): any | null {
    const entry = this.cache.get(key);

    if (!entry) return null;

    // Check expiry
    if (Date.now() > entry.expiry) {
      this.cache.delete(key);
      return null;
    }

    return entry.value;
  }

  // Cleanup expired entries
  cleanup() {
    const now = Date.now();
    for (const [key, entry] of this.cache.entries()) {
      if (now > entry.expiry) {
        this.cache.delete(key);
      }
    }
  }
}

// Usage
const cache = new CacheService();

async function getUser(id: string) {
  const cached = cache.get(`user:${id}`);
  if (cached) return cached;

  const user = await db.users.findById(id);
  cache.set(`user:${id}`, user, 5 * 60 * 1000); // 5 min TTL

  return user;
}
```

---

### 2. **Redis Caching**
```typescript
import Redis from 'ioredis';

const redis = new Redis({
  host: process.env.REDIS_HOST,
  port: parseInt(process.env.REDIS_PORT),
  maxRetriesPerRequest: 3,
  retryStrategy: (times) => Math.min(times * 50, 2000)
});

async function getCachedUser(id: string): Promise<User | null> {
  const cacheKey = `user:${id}`;

  // Try cache
  const cached = await redis.get(cacheKey);
  if (cached) {
    return JSON.parse(cached);
  }

  // Fetch from DB
  const user = await db.users.findById(id);

  // Store in cache (5 min TTL)
  await redis.setex(cacheKey, 300, JSON.stringify(user));

  return user;
}

// Invalidate cache on update
async function updateUser(id: string, data: UpdateUserDTO): Promise<User> {
  const user = await db.users.update(id, data);

  // Invalidate cache
  await redis.del(`user:${id}`);

  return user;
}
```

---

### 3. **Cache-Aside Pattern**
```typescript
class UserService {
  async getUser(id: string): Promise<User> {
    // 1. Check cache
    const cached = await cache.get(`user:${id}`);
    if (cached) return cached;

    // 2. Fetch from database
    const user = await this.userRepo.findById(id);

    // 3. Store in cache
    await cache.set(`user:${id}`, user, 300); // 5 min

    return user;
  }

  async updateUser(id: string, data: UpdateUserDTO): Promise<User> {
    // Update database
    const user = await this.userRepo.update(id, data);

    // Invalidate cache
    await cache.del(`user:${id}`);

    return user;
  }
}
```

---

### 4. **Memoization**
Cache function results based on arguments.

```typescript
function memoize<T extends (...args: any[]) => any>(fn: T): T {
  const cache = new Map<string, ReturnType<T>>();

  return ((...args: Parameters<T>) => {
    const key = JSON.stringify(args);

    if (cache.has(key)) {
      return cache.get(key);
    }

    const result = fn(...args);
    cache.set(key, result);

    return result;
  }) as T;
}

// Usage
const expensiveCalculation = memoize((a: number, b: number) => {
  // Complex calculation
  return a * b + Math.sqrt(a) * Math.sqrt(b);
});

console.log(expensiveCalculation(100, 200)); // Calculated
console.log(expensiveCalculation(100, 200)); // From cache
```

---

## Database Optimization

### 1. **Indexing**
```sql
-- Single column index
CREATE INDEX idx_users_email ON users(email);

-- Composite index (order matters!)
CREATE INDEX idx_orders_user_created ON orders(user_id, created_at DESC);

-- Partial index (smaller, faster)
CREATE INDEX idx_active_users ON users(id) WHERE status = 'active';

-- Covering index (includes all needed columns)
CREATE INDEX idx_users_lookup ON users(email) INCLUDE (id, name, created_at);
```

**When to Index**:
- Columns in WHERE clauses
- Columns in JOIN conditions
- Columns in ORDER BY
- Foreign keys

**When NOT to Index**:
- Small tables (< 1000 rows)
- Columns with high update frequency
- Columns with low cardinality (few unique values)

---

### 2. **Query Optimization**
```typescript
// ❌ Bad: N+1 query problem
async function getUsersWithPosts() {
  const users = await db.users.findMany();

  for (const user of users) {
    user.posts = await db.posts.findMany({ where: { userId: user.id } });
  }

  return users;
}
// This makes 1 + N queries (1 for users, then 1 per user for posts)

// ✅ Good: Eager loading with JOIN
async function getUsersWithPosts() {
  return db.users.findMany({
    include: {
      posts: true
    }
  });
}
// This makes 1 query with JOIN

// ✅ Alternative: DataLoader pattern (batching)
import DataLoader from 'dataloader';

const postLoader = new DataLoader(async (userIds: string[]) => {
  const posts = await db.posts.findMany({
    where: { userId: { in: userIds } }
  });

  // Group by userId
  const postsByUser = userIds.map(id =>
    posts.filter(post => post.userId === id)
  );

  return postsByUser;
});

// Usage batches multiple calls into one query
const user1Posts = await postLoader.load(user1.id);
const user2Posts = await postLoader.load(user2.id);
```

---

### 3. **Connection Pooling**
```typescript
import { Pool } from 'pg';

const pool = new Pool({
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT),
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  max: 20,                    // Max connections in pool
  min: 5,                     // Min connections to maintain
  idleTimeoutMillis: 30000,   // Close idle connections after 30s
  connectionTimeoutMillis: 2000
});

// Query with automatic connection management
async function getUser(id: string) {
  const result = await pool.query('SELECT * FROM users WHERE id = $1', [id]);
  return result.rows[0];
}
```

---

### 4. **Pagination**
```typescript
// ❌ Bad: Offset pagination (slow for large offsets)
async function getUsers(page: number, pageSize: number) {
  const offset = (page - 1) * pageSize;
  return db.users.findMany({
    skip: offset,     // Slow for large offsets
    take: pageSize
  });
}

// ✅ Good: Cursor-based pagination
async function getUsers(cursor?: string, limit: number = 20) {
  return db.users.findMany({
    take: limit,
    ...(cursor && {
      cursor: { id: cursor },
      skip: 1 // Skip the cursor itself
    }),
    orderBy: { id: 'asc' }
  });
}

// Response includes cursor for next page
{
  data: [...],
  nextCursor: users[users.length - 1]?.id
}
```

---

## API Performance

### 1. **Response Compression**
```typescript
import compression from 'compression';

app.use(compression({
  filter: (req, res) => {
    // Don't compress responses smaller than 1KB
    if (res.getHeader('Content-Length') < 1024) {
      return false;
    }
    return compression.filter(req, res);
  },
  level: 6  // Compression level (0-9)
}));
```

---

### 2. **Rate Limiting**
```typescript
import rateLimit from 'express-rate-limit';

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Max 100 requests per windowMs
  message: 'Too many requests from this IP',
  standardHeaders: true,
  legacyHeaders: false
});

app.use('/api/', limiter);
```

---

### 3. **Request Deduplication**
Prevent duplicate concurrent requests.

```typescript
class RequestDeduplicator {
  private pending = new Map<string, Promise<any>>();

  async dedupe<T>(key: string, fn: () => Promise<T>): Promise<T> {
    // If request is already in flight, return existing promise
    if (this.pending.has(key)) {
      return this.pending.get(key);
    }

    // Start new request
    const promise = fn().finally(() => {
      // Clean up after completion
      this.pending.delete(key);
    });

    this.pending.set(key, promise);

    return promise;
  }
}

const deduplicator = new RequestDeduplicator();

app.get('/api/users/:id', async (req, res) => {
  const userId = req.params.id;

  const user = await deduplicator.dedupe(`user:${userId}`, () =>
    db.users.findById(userId)
  );

  res.json(user);
});
```

---

## Frontend Performance

### 1. **Code Splitting**
```typescript
import { lazy, Suspense } from 'react';

// Lazy load routes
const Dashboard = lazy(() => import('./pages/Dashboard'));
const Settings = lazy(() => import('./pages/Settings'));

function App() {
  return (
    <Suspense fallback={<LoadingSpinner />}>
      <Routes>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/settings" element={<Settings />} />
      </Routes>
    </Suspense>
  );
}
```

---

### 2. **React Optimization**
```typescript
import { memo, useMemo, useCallback } from 'react';

// Memoize expensive components
const UserCard = memo(function UserCard({ user }: { user: User }) {
  return <div>{user.name}</div>;
});

// Memoize expensive calculations
function DataView({ data }: { data: Item[] }) {
  const sortedData = useMemo(() => {
    return data.sort((a, b) => a.value - b.value);
  }, [data]);

  return <div>{/* render sortedData */}</div>;
}

// Memoize callbacks to prevent re-renders
function Parent() {
  const [count, setCount] = useState(0);

  const handleClick = useCallback(() => {
    setCount(c => c + 1);
  }, []);

  return <Child onClick={handleClick} />;
}
```

---

### 3. **Virtual Scrolling**
For rendering large lists efficiently.

```typescript
import { FixedSizeList } from 'react-window';

function LargeList({ items }: { items: Item[] }) {
  const Row = ({ index, style }: RowProps) => (
    <div style={style}>
      {items[index].name}
    </div>
  );

  return (
    <FixedSizeList
      height={600}
      itemCount={items.length}
      itemSize={50}
      width="100%"
    >
      {Row}
    </FixedSizeList>
  );
}
```

---

### 4. **Image Optimization**
```typescript
// Lazy loading images
<img src="image.jpg" loading="lazy" alt="Description" />

// Responsive images
<img
  srcSet="
    image-320w.jpg 320w,
    image-640w.jpg 640w,
    image-1280w.jpg 1280w
  "
  sizes="(max-width: 320px) 280px,
         (max-width: 640px) 580px,
         1000px"
  src="image-640w.jpg"
  alt="Description"
/>

// Modern formats with fallback
<picture>
  <source srcSet="image.webp" type="image/webp" />
  <source srcSet="image.avif" type="image/avif" />
  <img src="image.jpg" alt="Description" />
</picture>
```

---

### 5. **Debouncing & Throttling**
```typescript
// Debounce: Wait until user stops typing
function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);

  return debouncedValue;
}

// Usage: Search as user types
function SearchBox() {
  const [query, setQuery] = useState('');
  const debouncedQuery = useDebounce(query, 500);

  useEffect(() => {
    if (debouncedQuery) {
      searchAPI(debouncedQuery);
    }
  }, [debouncedQuery]);

  return <input value={query} onChange={e => setQuery(e.target.value)} />;
}

// Throttle: Limit execution rate
function throttle<T extends (...args: any[]) => any>(
  fn: T,
  delay: number
): T {
  let lastCall = 0;

  return ((...args) => {
    const now = Date.now();
    if (now - lastCall >= delay) {
      lastCall = now;
      return fn(...args);
    }
  }) as T;
}

// Usage: Scroll handler
const handleScroll = throttle(() => {
  console.log('Scroll position:', window.scrollY);
}, 100);

window.addEventListener('scroll', handleScroll);
```

---

## Monitoring & Profiling

### 1. **Performance Monitoring**
```typescript
import { performance } from 'perf_hooks';

class PerformanceMonitor {
  private metrics = new Map<string, number[]>();

  measure<T>(name: string, fn: () => T): T {
    const start = performance.now();

    try {
      return fn();
    } finally {
      const duration = performance.now() - start;
      this.recordMetric(name, duration);
    }
  }

  async measureAsync<T>(name: string, fn: () => Promise<T>): Promise<T> {
    const start = performance.now();

    try {
      return await fn();
    } finally {
      const duration = performance.now() - start;
      this.recordMetric(name, duration);
    }
  }

  private recordMetric(name: string, duration: number) {
    if (!this.metrics.has(name)) {
      this.metrics.set(name, []);
    }

    this.metrics.get(name)!.push(duration);
  }

  getStats(name: string) {
    const values = this.metrics.get(name) || [];
    if (values.length === 0) return null;

    const sorted = [...values].sort((a, b) => a - b);

    return {
      count: values.length,
      min: sorted[0],
      max: sorted[sorted.length - 1],
      avg: values.reduce((a, b) => a + b, 0) / values.length,
      p50: sorted[Math.floor(sorted.length * 0.5)],
      p95: sorted[Math.floor(sorted.length * 0.95)],
      p99: sorted[Math.floor(sorted.length * 0.99)]
    };
  }
}

// Usage
const monitor = new PerformanceMonitor();

app.get('/api/users', async (req, res) => {
  const users = await monitor.measureAsync('get-users', () =>
    db.users.findMany()
  );

  res.json(users);
});

// Log stats periodically
setInterval(() => {
  const stats = monitor.getStats('get-users');
  logger.info('Performance stats', stats);
}, 60000); // Every minute
```

---

### 2. **Database Query Monitoring**
```typescript
// Log slow queries
const SLOW_QUERY_THRESHOLD_MS = 100;

pool.on('query', (query: any) => {
  const start = Date.now();

  query.on('end', () => {
    const duration = Date.now() - start;

    if (duration > SLOW_QUERY_THRESHOLD_MS) {
      logger.warn('Slow query detected', {
        query: query.text,
        duration,
        params: query.values
      });
    }
  });
});
```

---

### 3. **APM (Application Performance Monitoring)**
```typescript
// Using New Relic / DataDog / Sentry
import * as Sentry from '@sentry/node';

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  tracesSampleRate: 1.0,
  profilesSampleRate: 1.0
});

// Automatic performance tracking
app.use(Sentry.Handlers.requestHandler());
app.use(Sentry.Handlers.tracingHandler());

// Manual transaction tracking
const transaction = Sentry.startTransaction({
  op: 'user.fetch',
  name: 'Fetch User Data'
});

const user = await fetchUser(id);

transaction.finish();
```

---

## Performance Checklist

**Backend**:
- [ ] Database queries indexed properly
- [ ] No N+1 query problems
- [ ] Connection pooling configured
- [ ] Caching strategy implemented (Redis)
- [ ] Response compression enabled
- [ ] Rate limiting configured
- [ ] Slow query logging enabled

**Frontend**:
- [ ] Code splitting implemented
- [ ] Images optimized and lazy loaded
- [ ] Critical CSS inlined
- [ ] Unused code removed
- [ ] Bundle size < 200KB (gzipped)
- [ ] React.memo used for expensive components
- [ ] Virtual scrolling for long lists

**General**:
- [ ] Performance monitoring set up
- [ ] Metrics tracked (response time, throughput)
- [ ] Alerts configured for performance degradation
- [ ] Regular performance audits scheduled

---

**Last Updated**: 2026-01-22
**Maintained By**: Legendary Team Agents
