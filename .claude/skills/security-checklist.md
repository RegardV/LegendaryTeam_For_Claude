# 🔒 Security Checklist

## Purpose
Comprehensive security checklist covering OWASP Top 10, authentication/authorization, data protection, and secure coding practices for all Legendary Team agents.

---

## OWASP Top 10 (2021)

### A01:2021 - Broken Access Control

**Vulnerabilities**:
- Missing authorization checks
- Insecure Direct Object References (IDOR)
- Elevation of privilege

**Prevention**:
```typescript
// ❌ Bad: No authorization check
app.get('/api/users/:id', async (req, res) => {
  const user = await getUserById(req.params.id);
  res.json(user); // Any authenticated user can access any user
});

// ✅ Good: Proper authorization
app.get('/api/users/:id', authenticate, async (req, res) => {
  const requestedUserId = req.params.id;
  const currentUserId = req.user.id;

  // Users can only access their own data (or admins can access any)
  if (requestedUserId !== currentUserId && req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Forbidden' });
  }

  const user = await getUserById(requestedUserId);
  res.json(user);
});
```

**Checklist**:
- [ ] Implement authorization on all protected endpoints
- [ ] Deny by default (require explicit allow)
- [ ] Validate user permissions for every request
- [ ] Use role-based or attribute-based access control
- [ ] Log authorization failures for monitoring

---

### A02:2021 - Cryptographic Failures

**Vulnerabilities**:
- Storing passwords in plain text
- Weak encryption algorithms
- Transmitting sensitive data over HTTP

**Prevention**:
```typescript
// ❌ Bad: Plain text password
const user = {
  username: 'john',
  password: 'password123' // Plain text
};

// ✅ Good: Hashed password with bcrypt
import bcrypt from 'bcrypt';

async function createUser(username: string, password: string) {
  const saltRounds = 12;
  const passwordHash = await bcrypt.hash(password, saltRounds);

  return {
    username,
    passwordHash // Hashed
  };
}

async function verifyPassword(password: string, hash: string): Promise<boolean> {
  return bcrypt.compare(password, hash);
}
```

**Checklist**:
- [ ] Hash passwords with bcrypt (cost factor ≥12)
- [ ] Use HTTPS for all communications
- [ ] Encrypt sensitive data at rest (AES-256)
- [ ] Use secure random number generation
- [ ] Never store API keys or secrets in code
- [ ] Rotate keys and secrets regularly

---

### A03:2021 - Injection

**Vulnerabilities**:
- SQL Injection
- NoSQL Injection
- Command Injection
- XSS (Cross-Site Scripting)

**SQL Injection Prevention**:
```typescript
// ❌ Bad: String concatenation
const userId = req.params.id;
const query = `SELECT * FROM users WHERE id = '${userId}'`;
db.query(query); // Vulnerable to: ' OR '1'='1

// ✅ Good: Parameterized query
const userId = req.params.id;
const query = 'SELECT * FROM users WHERE id = $1';
db.query(query, [userId]); // Safe
```

**NoSQL Injection Prevention**:
```typescript
// ❌ Bad: Direct object
const username = req.body.username;
db.users.findOne({ username }); // Vulnerable to: { $gt: "" }

// ✅ Good: Type validation
const username = req.body.username;
if (typeof username !== 'string') {
  throw new ValidationError('Username must be a string');
}
db.users.findOne({ username });
```

**XSS Prevention**:
```typescript
// ❌ Bad: Rendering user input directly
<div>{userInput}</div> // Vulnerable to: <script>alert('XSS')</script>

// ✅ Good: Escape user input (React does this automatically)
<div>{escapeHtml(userInput)}</div>

function escapeHtml(text: string): string {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}
```

**Command Injection Prevention**:
```typescript
// ❌ Bad: Executing shell commands with user input
const filename = req.body.filename;
exec(`cat ${filename}`); // Vulnerable to: "; rm -rf /"

// ✅ Good: Use libraries instead of shell commands
import fs from 'fs/promises';
const filename = req.body.filename;

// Validate and sanitize
if (!/^[a-zA-Z0-9_-]+\.txt$/.test(filename)) {
  throw new ValidationError('Invalid filename');
}

const content = await fs.readFile(path.join('/safe/directory', filename), 'utf-8');
```

**Checklist**:
- [ ] Use parameterized queries for SQL
- [ ] Validate input types for NoSQL
- [ ] Escape HTML output to prevent XSS
- [ ] Use Content Security Policy headers
- [ ] Avoid executing shell commands with user input
- [ ] Validate and sanitize all user inputs

---

### A04:2021 - Insecure Design

**Vulnerabilities**:
- Missing security requirements
- No threat modeling
- Insecure defaults

**Prevention**:
```typescript
// ✅ Good: Secure by default configuration
const config = {
  session: {
    secure: true,           // HTTPS only
    httpOnly: true,         // No JavaScript access
    sameSite: 'strict',     // CSRF protection
    maxAge: 3600000         // 1 hour expiry
  },
  rateLimit: {
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100                   // Max 100 requests per window
  },
  password: {
    minLength: 12,
    requireUppercase: true,
    requireLowercase: true,
    requireNumbers: true,
    requireSpecialChars: true
  }
};
```

**Checklist**:
- [ ] Define security requirements early
- [ ] Perform threat modeling
- [ ] Use secure defaults
- [ ] Implement defense in depth
- [ ] Follow principle of least privilege

---

### A05:2021 - Security Misconfiguration

**Vulnerabilities**:
- Default credentials
- Verbose error messages
- Unnecessary features enabled

**Prevention**:
```typescript
// ❌ Bad: Exposing error details
app.use((err, req, res, next) => {
  res.status(500).json({
    error: err.message,
    stack: err.stack // Exposes internal structure
  });
});

// ✅ Good: Generic error in production
app.use((err, req, res, next) => {
  logger.error('Error occurred', { error: err, path: req.path });

  const response = process.env.NODE_ENV === 'production'
    ? { error: 'Internal server error' }
    : { error: err.message, stack: err.stack };

  res.status(err.statusCode || 500).json(response);
});
```

**Checklist**:
- [ ] Remove default credentials
- [ ] Disable debug mode in production
- [ ] Hide error details from users
- [ ] Keep dependencies updated
- [ ] Remove unnecessary features
- [ ] Set security headers properly

---

### A06:2021 - Vulnerable and Outdated Components

**Prevention**:
```bash
# Check for vulnerabilities
npm audit

# Update dependencies
npm update

# Check for outdated packages
npm outdated
```

**Checklist**:
- [ ] Run `npm audit` regularly
- [ ] Update dependencies monthly
- [ ] Monitor security advisories
- [ ] Use dependency scanning tools (Snyk, Dependabot)
- [ ] Remove unused dependencies

---

### A07:2021 - Identification and Authentication Failures

**Vulnerabilities**:
- Weak password requirements
- No rate limiting on login
- Session fixation

**Prevention**:
```typescript
// Password strength validation
function validatePassword(password: string): boolean {
  const minLength = 12;
  const hasUppercase = /[A-Z]/.test(password);
  const hasLowercase = /[a-z]/.test(password);
  const hasNumber = /[0-9]/.test(password);
  const hasSpecial = /[!@#$%^&*]/.test(password);

  return (
    password.length >= minLength &&
    hasUppercase &&
    hasLowercase &&
    hasNumber &&
    hasSpecial
  );
}

// Rate limiting on login
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 attempts
  message: 'Too many login attempts, please try again later'
});

app.post('/api/login', loginLimiter, async (req, res) => {
  // Login logic
});

// Multi-factor authentication
async function verifyMFA(userId: string, code: string): Promise<boolean> {
  const secret = await getUserMFASecret(userId);
  return speakeasy.totp.verify({
    secret,
    encoding: 'base32',
    token: code,
    window: 1
  });
}
```

**Checklist**:
- [ ] Enforce strong password requirements (≥12 chars, mixed case, numbers, special)
- [ ] Implement rate limiting on login
- [ ] Use multi-factor authentication for sensitive accounts
- [ ] Implement account lockout after failed attempts
- [ ] Use secure session management
- [ ] Regenerate session IDs after login

---

### A08:2021 - Software and Data Integrity Failures

**Vulnerabilities**:
- Unsigned updates
- Insecure deserialization
- Untrusted data

**Prevention**:
```typescript
// ❌ Bad: Deserializing untrusted data
const userData = JSON.parse(req.body.data);
eval(userData.code); // Extremely dangerous

// ✅ Good: Validate before deserializing
const schema = z.object({
  name: z.string(),
  email: z.string().email(),
  age: z.number().int().positive()
});

const userData = schema.parse(JSON.parse(req.body.data));
```

**Checklist**:
- [ ] Verify integrity of downloads (checksums)
- [ ] Use signed packages and updates
- [ ] Never deserialize untrusted data
- [ ] Validate all inputs against schema
- [ ] Use Subresource Integrity (SRI) for CDN resources

---

### A09:2021 - Security Logging and Monitoring Failures

**Prevention**:
```typescript
import winston from 'winston';

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});

// Log security events
function logSecurityEvent(event: string, details: any) {
  logger.warn('Security event', {
    event,
    ...details,
    timestamp: new Date().toISOString()
  });
}

// Usage
app.post('/api/login', async (req, res) => {
  const { username, password } = req.body;

  const user = await authenticateUser(username, password);

  if (!user) {
    logSecurityEvent('failed_login', {
      username,
      ip: req.ip,
      userAgent: req.headers['user-agent']
    });
    return res.status(401).json({ error: 'Invalid credentials' });
  }

  logSecurityEvent('successful_login', {
    userId: user.id,
    ip: req.ip
  });

  res.json({ token: generateToken(user) });
});
```

**Checklist**:
- [ ] Log all authentication events (success/failure)
- [ ] Log authorization failures
- [ ] Log input validation failures
- [ ] Monitor logs for suspicious patterns
- [ ] Set up alerts for security events
- [ ] Protect log files from tampering
- [ ] Don't log sensitive data (passwords, tokens)

---

### A10:2021 - Server-Side Request Forgery (SSRF)

**Vulnerabilities**:
- Fetching user-provided URLs without validation

**Prevention**:
```typescript
// ❌ Bad: Fetching any URL
app.post('/api/fetch', async (req, res) => {
  const url = req.body.url;
  const response = await fetch(url); // Can access internal services
  res.json(await response.json());
});

// ✅ Good: Whitelist allowed domains
const ALLOWED_DOMAINS = ['api.example.com', 'cdn.example.com'];

app.post('/api/fetch', async (req, res) => {
  const url = new URL(req.body.url);

  // Validate domain
  if (!ALLOWED_DOMAINS.includes(url.hostname)) {
    return res.status(400).json({ error: 'Domain not allowed' });
  }

  // Prevent access to private networks
  const ip = await dns.resolve(url.hostname);
  if (isPrivateIP(ip)) {
    return res.status(400).json({ error: 'Cannot access private networks' });
  }

  const response = await fetch(url.toString());
  res.json(await response.json());
});
```

**Checklist**:
- [ ] Whitelist allowed domains/IPs
- [ ] Block access to private networks (127.0.0.1, 192.168.x.x, 10.x.x.x)
- [ ] Validate and sanitize URLs
- [ ] Use network segmentation

---

## Authentication Best Practices

### JWT Implementation
```typescript
import jwt from 'jsonwebtoken';

// Generate token
function generateAccessToken(user: User): string {
  return jwt.sign(
    {
      userId: user.id,
      email: user.email,
      role: user.role
    },
    process.env.JWT_SECRET,
    { expiresIn: '15m' } // Short expiry
  );
}

function generateRefreshToken(user: User): string {
  return jwt.sign(
    { userId: user.id },
    process.env.REFRESH_SECRET,
    { expiresIn: '7d' }
  );
}

// Verify token
function verifyAccessToken(token: string) {
  try {
    return jwt.verify(token, process.env.JWT_SECRET);
  } catch (error) {
    throw new UnauthorizedError('Invalid or expired token');
  }
}
```

**Checklist**:
- [ ] Use short expiry for access tokens (≤15 min)
- [ ] Use refresh tokens for long sessions
- [ ] Store refresh tokens securely (httpOnly cookie)
- [ ] Implement token revocation
- [ ] Rotate secrets regularly

---

## Data Protection

### Encryption at Rest
```typescript
import crypto from 'crypto';

const algorithm = 'aes-256-gcm';
const key = crypto.scryptSync(process.env.ENCRYPTION_KEY, 'salt', 32);

function encrypt(text: string): { encrypted: string; iv: string; tag: string } {
  const iv = crypto.randomBytes(16);
  const cipher = crypto.createCipheriv(algorithm, key, iv);

  let encrypted = cipher.update(text, 'utf8', 'hex');
  encrypted += cipher.final('hex');

  return {
    encrypted,
    iv: iv.toString('hex'),
    tag: cipher.getAuthTag().toString('hex')
  };
}

function decrypt(encrypted: string, iv: string, tag: string): string {
  const decipher = crypto.createDecipheriv(
    algorithm,
    key,
    Buffer.from(iv, 'hex')
  );

  decipher.setAuthTag(Buffer.from(tag, 'hex'));

  let decrypted = decipher.update(encrypted, 'hex', 'utf8');
  decrypted += decipher.final('utf8');

  return decrypted;
}
```

---

## Security Headers

```typescript
import helmet from 'helmet';

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", "'unsafe-inline'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", 'data:', 'https:'],
      connectSrc: ["'self'"],
      fontSrc: ["'self'"],
      objectSrc: ["'none'"],
      mediaSrc: ["'self'"],
      frameSrc: ["'none'"]
    }
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  }
}));

// Additional headers
app.use((req, res, next) => {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-XSS-Protection', '1; mode=block');
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
  next();
});
```

---

## Security Audit Checklist

**Before Deployment**:
- [ ] All dependencies updated and audited
- [ ] Security headers configured
- [ ] HTTPS enforced
- [ ] Input validation on all endpoints
- [ ] Authentication/authorization implemented
- [ ] Sensitive data encrypted
- [ ] Logging and monitoring set up
- [ ] Rate limiting configured
- [ ] Error handling doesn't leak info
- [ ] Secrets stored in environment variables

**Regular Maintenance**:
- [ ] Weekly dependency audits
- [ ] Monthly security reviews
- [ ] Quarterly penetration testing
- [ ] Regular log analysis
- [ ] Key rotation schedule

---

**Last Updated**: 2026-01-22
**Maintained By**: Legendary Team Agents
