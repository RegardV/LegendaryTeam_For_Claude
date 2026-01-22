# 🔒 Security Rules

## Purpose
Mandatory security rules that all Legendary Team agents MUST follow when writing code.

---

## Non-Negotiable Security Rules

### 1. **NEVER Store Secrets in Code**
```typescript
// ❌ FORBIDDEN
const API_KEY = 'sk-1234567890abcdef';
const DB_PASSWORD = 'my_password123';

// ✅ REQUIRED
const API_KEY = process.env.API_KEY;
const DB_PASSWORD = process.env.DB_PASSWORD;
```

**Rule**: All secrets MUST be stored in environment variables, never hardcoded.

---

### 2. **ALWAYS Use Parameterized Queries**
```typescript
// ❌ FORBIDDEN - SQL Injection vulnerability
const userId = req.params.id;
db.query(`SELECT * FROM users WHERE id = '${userId}'`);

// ✅ REQUIRED
const userId = req.params.id;
db.query('SELECT * FROM users WHERE id = $1', [userId]);
```

**Rule**: NEVER concatenate user input into SQL queries. Always use parameterized queries.

---

### 3. **ALWAYS Validate User Input**
```typescript
// ❌ FORBIDDEN - No validation
app.post('/api/users', async (req, res) => {
  const user = await createUser(req.body);
  res.json(user);
});

// ✅ REQUIRED
import { z } from 'zod';

const userSchema = z.object({
  name: z.string().min(1).max(100),
  email: z.string().email(),
  age: z.number().int().positive().max(150)
});

app.post('/api/users', async (req, res) => {
  const validated = userSchema.parse(req.body);
  const user = await createUser(validated);
  res.json(user);
});
```

**Rule**: ALL user inputs MUST be validated before use.

---

### 4. **ALWAYS Implement Authentication & Authorization**
```typescript
// ❌ FORBIDDEN - No auth checks
app.delete('/api/users/:id', async (req, res) => {
  await deleteUser(req.params.id);
  res.json({ success: true });
});

// ✅ REQUIRED
app.delete('/api/users/:id', authenticate, async (req, res) => {
  const targetUserId = req.params.id;
  const currentUserId = req.user.id;

  // Authorization: Only admins or the user themselves can delete
  if (targetUserId !== currentUserId && req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Forbidden' });
  }

  await deleteUser(targetUserId);
  res.json({ success: true });
});
```

**Rule**: Protected endpoints MUST have both authentication AND authorization checks.

---

### 5. **ALWAYS Hash Passwords**
```typescript
// ❌ FORBIDDEN - Plain text password
const user = {
  username: 'john',
  password: req.body.password // Plain text
};

// ✅ REQUIRED
import bcrypt from 'bcrypt';

const user = {
  username: 'john',
  passwordHash: await bcrypt.hash(req.body.password, 12)
};
```

**Rule**: Passwords MUST be hashed with bcrypt (cost factor ≥12). NEVER store plain text passwords.

---

### 6. **ALWAYS Use HTTPS**
```typescript
// ❌ FORBIDDEN
const app = express();
app.listen(3000);

// ✅ REQUIRED (Production)
import https from 'https';
import fs from 'fs';

const options = {
  key: fs.readFileSync(process.env.SSL_KEY_PATH),
  cert: fs.readFileSync(process.env.SSL_CERT_PATH)
};

https.createServer(options, app).listen(443);
```

**Rule**: Production servers MUST use HTTPS. HTTP is only acceptable for local development.

---

### 7. **NEVER Log Sensitive Data**
```typescript
// ❌ FORBIDDEN
logger.info('User login', {
  username: user.username,
  password: user.password, // NEVER log passwords
  token: user.token         // NEVER log tokens
});

// ✅ REQUIRED
logger.info('User login', {
  userId: user.id,
  username: user.username
  // No sensitive data
});
```

**Rule**: NEVER log passwords, tokens, API keys, credit card numbers, or other sensitive data.

---

### 8. **ALWAYS Escape HTML Output**
```typescript
// ❌ FORBIDDEN - XSS vulnerability
<div dangerouslySetInnerHTML={{ __html: userInput }} />

// ✅ REQUIRED (React auto-escapes)
<div>{userInput}</div>

// ✅ REQUIRED (Manual escaping if needed)
function escapeHtml(text: string): string {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}
```

**Rule**: User input MUST be escaped before rendering in HTML.

---

### 9. **ALWAYS Use Secure Session Configuration**
```typescript
// ❌ FORBIDDEN
app.use(session({
  secret: 'keyboard cat',
  cookie: {}
}));

// ✅ REQUIRED
app.use(session({
  secret: process.env.SESSION_SECRET,
  cookie: {
    httpOnly: true,      // Prevent JavaScript access
    secure: true,        // HTTPS only
    sameSite: 'strict',  // CSRF protection
    maxAge: 3600000      // 1 hour
  },
  resave: false,
  saveUninitialized: false
}));
```

**Rule**: Sessions MUST use secure configuration.

---

### 10. **ALWAYS Set Security Headers**
```typescript
// ✅ REQUIRED
import helmet from 'helmet';

app.use(helmet({
  contentSecurityPolicy: true,
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true
  }
}));

app.use((req, res, next) => {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-XSS-Protection', '1; mode=block');
  next();
});
```

**Rule**: Security headers MUST be configured.

---

### 11. **ALWAYS Implement Rate Limiting**
```typescript
// ✅ REQUIRED
import rateLimit from 'express-rate-limit';

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100                  // Limit each IP to 100 requests per windowMs
});

app.use('/api/', limiter);

// Stricter limit for auth endpoints
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5
});

app.use('/api/login', authLimiter);
```

**Rule**: Public APIs MUST have rate limiting to prevent abuse.

---

### 12. **NEVER Execute User Input as Code**
```typescript
// ❌ FORBIDDEN - Remote code execution vulnerability
eval(req.body.code);
new Function(req.body.code)();
exec(req.body.command);

// ✅ REQUIRED
// If you absolutely need to execute code, use a sandboxed environment
// with strict validation and timeouts. Prefer to avoid this entirely.
```

**Rule**: NEVER use `eval()`, `new Function()`, or `exec()` with user input.

---

### 13. **ALWAYS Validate File Uploads**
```typescript
// ❌ FORBIDDEN
app.post('/upload', upload.single('file'), (req, res) => {
  const file = req.file;
  fs.writeFileSync(`./uploads/${file.originalname}`, file.buffer);
});

// ✅ REQUIRED
import { v4 as uuidv4 } from 'uuid';
import path from 'path';

const allowedMimeTypes = ['image/jpeg', 'image/png', 'image/gif'];
const maxSize = 5 * 1024 * 1024; // 5MB

app.post('/upload', upload.single('file'), (req, res) => {
  const file = req.file;

  // Validate MIME type
  if (!allowedMimeTypes.includes(file.mimetype)) {
    return res.status(400).json({ error: 'Invalid file type' });
  }

  // Validate size
  if (file.size > maxSize) {
    return res.status(400).json({ error: 'File too large' });
  }

  // Use safe filename
  const ext = path.extname(file.originalname);
  const safeFilename = `${uuidv4()}${ext}`;

  fs.writeFileSync(`./uploads/${safeFilename}`, file.buffer);
  res.json({ filename: safeFilename });
});
```

**Rule**: File uploads MUST validate type, size, and use safe filenames.

---

### 14. **ALWAYS Update Dependencies**
```bash
# ✅ REQUIRED - Run regularly
npm audit
npm audit fix

# Check for outdated packages
npm outdated
```

**Rule**: Dependencies MUST be audited and updated regularly (at least monthly).

---

### 15. **NEVER Trust Client-Side Validation**
```typescript
// ❌ FORBIDDEN - Relying only on client validation
// Client:
<input type="email" required />

// Server: No validation

// ✅ REQUIRED - Always validate on server
// Client:
<input type="email" required />

// Server:
const emailSchema = z.string().email();
const email = emailSchema.parse(req.body.email);
```

**Rule**: Client-side validation is for UX only. ALWAYS validate on the server.

---

## Security Testing Requirements

### Before Deploying
- [ ] Run `npm audit` and fix all critical/high vulnerabilities
- [ ] Test authentication/authorization flows
- [ ] Test input validation for all endpoints
- [ ] Verify secrets are in environment variables
- [ ] Check security headers are set
- [ ] Confirm HTTPS is enforced
- [ ] Test rate limiting
- [ ] Review logs for sensitive data leakage

---

## Incident Response

### If a Security Vulnerability is Found
1. **Immediately** document the vulnerability
2. **Assess** the impact and severity
3. **Fix** the vulnerability
4. **Test** the fix thoroughly
5. **Deploy** the fix as soon as possible
6. **Notify** affected users if necessary
7. **Review** how the vulnerability was introduced
8. **Update** processes to prevent recurrence

---

## Security Code Review Checklist

When reviewing code, ALWAYS check:
- [ ] No secrets hardcoded
- [ ] All user inputs validated
- [ ] Parameterized queries used
- [ ] Authentication implemented
- [ ] Authorization implemented
- [ ] Passwords hashed
- [ ] HTTPS enforced
- [ ] Security headers set
- [ ] Rate limiting implemented
- [ ] No sensitive data logged
- [ ] File uploads validated
- [ ] Dependencies up to date

---

**REMEMBER**: Security is NOT optional. These rules MUST be followed on every commit.

**Last Updated**: 2026-01-22
**Maintained By**: Legendary Team Agents
