# 🔧 Backend Patterns

## Purpose
Collection of proven backend architecture patterns, API design principles, and server-side best practices for building robust, scalable services.

---

## Architecture Patterns

### 1. **Layered Architecture**
```
┌─────────────────────────┐
│   Presentation Layer    │ ← Controllers, Routes, Middleware
├─────────────────────────┤
│   Business Logic Layer  │ ← Services, Use Cases
├─────────────────────────┤
│   Data Access Layer     │ ← Repositories, ORMs
├─────────────────────────┤
│   Database Layer        │ ← PostgreSQL, MongoDB, Redis
└─────────────────────────┘
```

**Benefits**:
- Clear separation of concerns
- Easy to test each layer independently
- Maintainable and scalable

**Implementation**:
```typescript
// Controller Layer
export class UserController {
  constructor(private userService: UserService) {}

  async getUser(req: Request, res: Response) {
    const user = await this.userService.getUserById(req.params.id);
    res.json(user);
  }
}

// Service Layer
export class UserService {
  constructor(private userRepository: UserRepository) {}

  async getUserById(id: string): Promise<User> {
    const user = await this.userRepository.findById(id);
    if (!user) {
      throw new NotFoundError('User not found');
    }
    return user;
  }
}

// Repository Layer
export class UserRepository {
  async findById(id: string): Promise<User | null> {
    return db.users.findOne({ id });
  }
}
```

---

### 2. **Repository Pattern**
Abstracts data access logic, making it easier to switch databases or add caching.

```typescript
interface IUserRepository {
  findById(id: string): Promise<User | null>;
  findByEmail(email: string): Promise<User | null>;
  create(user: CreateUserDTO): Promise<User>;
  update(id: string, data: UpdateUserDTO): Promise<User>;
  delete(id: string): Promise<void>;
}

export class PostgresUserRepository implements IUserRepository {
  async findById(id: string): Promise<User | null> {
    const result = await db.query('SELECT * FROM users WHERE id = $1', [id]);
    return result.rows[0] || null;
  }

  // ... other methods
}

export class MongoUserRepository implements IUserRepository {
  async findById(id: string): Promise<User | null> {
    return await User.findOne({ _id: id });
  }

  // ... other methods
}
```

---

### 3. **Service Pattern**
Encapsulates business logic, keeping controllers thin.

```typescript
export class OrderService {
  constructor(
    private orderRepo: OrderRepository,
    private paymentService: PaymentService,
    private emailService: EmailService
  ) {}

  async createOrder(userId: string, items: OrderItem[]): Promise<Order> {
    // Business logic
    const total = this.calculateTotal(items);

    // Create order
    const order = await this.orderRepo.create({
      userId,
      items,
      total,
      status: 'pending'
    });

    // Process payment
    await this.paymentService.charge(userId, total);

    // Update order status
    await this.orderRepo.update(order.id, { status: 'paid' });

    // Send confirmation
    await this.emailService.sendOrderConfirmation(order);

    return order;
  }

  private calculateTotal(items: OrderItem[]): number {
    return items.reduce((sum, item) => sum + (item.price * item.quantity), 0);
  }
}
```

---

### 4. **Middleware Pattern**
Chain reusable request processing logic.

```typescript
// Authentication middleware
export const authenticate = async (req: Request, res: Response, next: NextFunction) => {
  const token = req.headers.authorization?.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
};

// Rate limiting middleware
export const rateLimit = (maxRequests: number, windowMs: number) => {
  const requests = new Map<string, number[]>();

  return (req: Request, res: Response, next: NextFunction) => {
    const key = req.ip;
    const now = Date.now();
    const windowStart = now - windowMs;

    const userRequests = requests.get(key) || [];
    const recentRequests = userRequests.filter(time => time > windowStart);

    if (recentRequests.length >= maxRequests) {
      return res.status(429).json({ error: 'Too many requests' });
    }

    recentRequests.push(now);
    requests.set(key, recentRequests);
    next();
  };
};

// Usage
app.use('/api', authenticate, rateLimit(100, 60000));
```

---

## API Design Patterns

### 1. **RESTful API Design**

**Resource Naming**:
```
GET    /api/users           # List users
GET    /api/users/:id       # Get user
POST   /api/users           # Create user
PUT    /api/users/:id       # Update user (full)
PATCH  /api/users/:id       # Update user (partial)
DELETE /api/users/:id       # Delete user

# Nested resources
GET    /api/users/:id/orders      # User's orders
POST   /api/users/:id/orders      # Create order for user
```

**Response Format**:
```typescript
// Success response
{
  "data": {
    "id": "123",
    "name": "John Doe",
    "email": "john@example.com"
  },
  "meta": {
    "timestamp": "2026-01-22T10:30:00Z"
  }
}

// Error response
{
  "error": {
    "code": "USER_NOT_FOUND",
    "message": "User with ID 123 not found",
    "details": {}
  },
  "meta": {
    "timestamp": "2026-01-22T10:30:00Z",
    "requestId": "abc-123"
  }
}

// Paginated list response
{
  "data": [
    { "id": "1", "name": "User 1" },
    { "id": "2", "name": "User 2" }
  ],
  "meta": {
    "page": 1,
    "pageSize": 20,
    "totalPages": 5,
    "totalCount": 100
  },
  "links": {
    "self": "/api/users?page=1",
    "next": "/api/users?page=2",
    "prev": null,
    "first": "/api/users?page=1",
    "last": "/api/users?page=5"
  }
}
```

---

### 2. **GraphQL Pattern**
```typescript
// Schema definition
const typeDefs = gql`
  type User {
    id: ID!
    name: String!
    email: String!
    posts: [Post!]!
  }

  type Post {
    id: ID!
    title: String!
    content: String!
    author: User!
  }

  type Query {
    user(id: ID!): User
    users(limit: Int, offset: Int): [User!]!
  }

  type Mutation {
    createUser(input: CreateUserInput!): User!
    updateUser(id: ID!, input: UpdateUserInput!): User!
  }

  input CreateUserInput {
    name: String!
    email: String!
  }
`;

// Resolvers
const resolvers = {
  Query: {
    user: async (_, { id }, { dataSources }) => {
      return dataSources.userAPI.getUserById(id);
    },
    users: async (_, { limit, offset }, { dataSources }) => {
      return dataSources.userAPI.getUsers(limit, offset);
    }
  },
  Mutation: {
    createUser: async (_, { input }, { dataSources }) => {
      return dataSources.userAPI.createUser(input);
    }
  },
  User: {
    posts: async (user, _, { dataSources }) => {
      return dataSources.postAPI.getPostsByUserId(user.id);
    }
  }
};
```

---

### 3. **API Versioning**

**URL Versioning**:
```typescript
app.use('/api/v1', v1Router);
app.use('/api/v2', v2Router);

// v1: GET /api/v1/users
// v2: GET /api/v2/users
```

**Header Versioning**:
```typescript
app.use((req, res, next) => {
  const version = req.headers['api-version'] || 'v1';
  req.apiVersion = version;
  next();
});

router.get('/users', (req, res) => {
  if (req.apiVersion === 'v2') {
    return res.json(getUsersV2());
  }
  return res.json(getUsersV1());
});
```

---

## Data Patterns

### 1. **Database Transactions**
```typescript
async function transferFunds(fromId: string, toId: string, amount: number) {
  const client = await db.pool.connect();

  try {
    await client.query('BEGIN');

    // Debit from account
    await client.query(
      'UPDATE accounts SET balance = balance - $1 WHERE id = $2',
      [amount, fromId]
    );

    // Credit to account
    await client.query(
      'UPDATE accounts SET balance = balance + $1 WHERE id = $2',
      [amount, toId]
    );

    // Create transaction record
    await client.query(
      'INSERT INTO transactions (from_id, to_id, amount) VALUES ($1, $2, $3)',
      [fromId, toId, amount]
    );

    await client.query('COMMIT');
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}
```

---

### 2. **Caching Strategy**
```typescript
export class CachedUserService {
  constructor(
    private userRepo: UserRepository,
    private cache: RedisClient
  ) {}

  async getUserById(id: string): Promise<User> {
    const cacheKey = `user:${id}`;

    // Try cache first
    const cached = await this.cache.get(cacheKey);
    if (cached) {
      return JSON.parse(cached);
    }

    // Fetch from database
    const user = await this.userRepo.findById(id);

    // Store in cache (30 minute TTL)
    await this.cache.setex(cacheKey, 1800, JSON.stringify(user));

    return user;
  }

  async updateUser(id: string, data: UpdateUserDTO): Promise<User> {
    const user = await this.userRepo.update(id, data);

    // Invalidate cache
    await this.cache.del(`user:${id}`);

    return user;
  }
}
```

**Cache Patterns**:
- **Cache-Aside**: Application manages cache (shown above)
- **Write-Through**: Write to cache and DB simultaneously
- **Write-Behind**: Write to cache, async write to DB

---

### 3. **Database Indexing**
```sql
-- Single column index
CREATE INDEX idx_users_email ON users(email);

-- Composite index
CREATE INDEX idx_orders_user_date ON orders(user_id, created_at DESC);

-- Partial index
CREATE INDEX idx_active_users ON users(id) WHERE status = 'active';

-- Full-text search index
CREATE INDEX idx_posts_search ON posts USING GIN(to_tsvector('english', content));
```

---

## Error Handling Patterns

### 1. **Custom Error Classes**
```typescript
export class AppError extends Error {
  constructor(
    public statusCode: number,
    public code: string,
    message: string,
    public isOperational = true
  ) {
    super(message);
    Object.setPrototypeOf(this, AppError.prototype);
  }
}

export class NotFoundError extends AppError {
  constructor(message: string) {
    super(404, 'NOT_FOUND', message);
  }
}

export class ValidationError extends AppError {
  constructor(message: string, public details: any) {
    super(400, 'VALIDATION_ERROR', message);
  }
}

export class UnauthorizedError extends AppError {
  constructor(message: string) {
    super(401, 'UNAUTHORIZED', message);
  }
}
```

---

### 2. **Global Error Handler**
```typescript
export const errorHandler = (
  error: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  // Log error
  logger.error('Error occurred', {
    error: error.message,
    stack: error.stack,
    path: req.path,
    method: req.method
  });

  // Operational errors (known errors)
  if (error instanceof AppError && error.isOperational) {
    return res.status(error.statusCode).json({
      error: {
        code: error.code,
        message: error.message,
        details: error instanceof ValidationError ? error.details : undefined
      }
    });
  }

  // Programming errors (unknown errors)
  res.status(500).json({
    error: {
      code: 'INTERNAL_SERVER_ERROR',
      message: 'An unexpected error occurred'
    }
  });
};

// Usage
app.use(errorHandler);
```

---

## Authentication & Authorization

### 1. **JWT Authentication**
```typescript
export class AuthService {
  generateToken(user: User): string {
    return jwt.sign(
      {
        userId: user.id,
        email: user.email,
        role: user.role
      },
      process.env.JWT_SECRET,
      { expiresIn: '1h' }
    );
  }

  generateRefreshToken(user: User): string {
    return jwt.sign(
      { userId: user.id },
      process.env.REFRESH_SECRET,
      { expiresIn: '7d' }
    );
  }

  async login(email: string, password: string) {
    const user = await this.userRepo.findByEmail(email);
    if (!user || !await bcrypt.compare(password, user.passwordHash)) {
      throw new UnauthorizedError('Invalid credentials');
    }

    return {
      accessToken: this.generateToken(user),
      refreshToken: this.generateRefreshToken(user),
      user: { id: user.id, email: user.email, role: user.role }
    };
  }
}
```

---

### 2. **Role-Based Access Control (RBAC)**
```typescript
enum Permission {
  READ_USERS = 'read:users',
  WRITE_USERS = 'write:users',
  DELETE_USERS = 'delete:users',
  READ_POSTS = 'read:posts',
  WRITE_POSTS = 'write:posts'
}

const rolePermissions: Record<string, Permission[]> = {
  admin: [
    Permission.READ_USERS,
    Permission.WRITE_USERS,
    Permission.DELETE_USERS,
    Permission.READ_POSTS,
    Permission.WRITE_POSTS
  ],
  user: [
    Permission.READ_POSTS,
    Permission.WRITE_POSTS
  ],
  guest: [
    Permission.READ_POSTS
  ]
};

export const requirePermission = (permission: Permission) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const userPermissions = rolePermissions[req.user.role] || [];

    if (!userPermissions.includes(permission)) {
      return res.status(403).json({
        error: { code: 'FORBIDDEN', message: 'Insufficient permissions' }
      });
    }

    next();
  };
};

// Usage
router.delete('/users/:id',
  authenticate,
  requirePermission(Permission.DELETE_USERS),
  userController.deleteUser
);
```

---

## Background Jobs & Queues

### 1. **Job Queue Pattern (Bull/BullMQ)**
```typescript
import Bull from 'bull';

const emailQueue = new Bull('email', {
  redis: { host: 'localhost', port: 6379 }
});

// Producer
export async function sendWelcomeEmail(userId: string) {
  await emailQueue.add('welcome', { userId }, {
    attempts: 3,
    backoff: { type: 'exponential', delay: 2000 }
  });
}

// Consumer
emailQueue.process('welcome', async (job) => {
  const { userId } = job.data;
  const user = await getUserById(userId);
  await emailService.send({
    to: user.email,
    subject: 'Welcome!',
    template: 'welcome',
    data: { name: user.name }
  });
});

// Error handling
emailQueue.on('failed', (job, error) => {
  logger.error('Email job failed', { jobId: job.id, error });
});
```

---

## Performance Patterns

### 1. **Database Connection Pooling**
```typescript
import { Pool } from 'pg';

const pool = new Pool({
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT),
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  max: 20,              // Max connections
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000
});
```

---

### 2. **Response Compression**
```typescript
import compression from 'compression';

app.use(compression({
  filter: (req, res) => {
    if (req.headers['x-no-compression']) {
      return false;
    }
    return compression.filter(req, res);
  },
  level: 6  // Compression level (0-9)
}));
```

---

**Last Updated**: 2026-01-22
**Maintained By**: Legendary Team Agents
