# /plan - Implementation Planning & Strategy

Create detailed implementation plans before coding, ensuring clear strategy and preventing over-engineering.

---

## Usage

```bash
# Create implementation plan for a feature
/plan "Add user authentication with OAuth2"

# Plan with specific requirements
/plan "Build shopping cart" --requirements "must support multiple currencies, inventory tracking"

# Plan refactoring
/plan refactor "migrate from Redux to Zustand"

# Plan architecture change
/plan architecture "add microservices for payment processing"

# Generate step-by-step plan
/plan "implement real-time notifications" --detailed
```

---

## What This Command Does

1. **Analyzes** the requested feature or change
2. **Breaks down** into concrete, actionable steps
3. **Identifies** dependencies and blockers
4. **Estimates** effort and complexity
5. **Suggests** architecture and approach
6. **Creates** task checklist
7. **Highlights** risks and trade-offs

---

## Command Flow

```markdown
Step 1: Understand requirement
  → Parse user request
  → Identify scope and goals
  → Clarify any ambiguities

Step 2: Analyze current state
  → Review existing code
  → Identify what exists
  → Find integration points

Step 3: Design approach
  → Choose architecture pattern
  → Select technologies
  → Define data models

Step 4: Break into tasks
  → Create step-by-step plan
  → Identify dependencies
  → Estimate complexity

Step 5: Highlight considerations
  → Security implications
  → Performance impacts
  → Testing requirements
  → Deployment needs

Step 6: Create actionable output
  → Task checklist
  → File locations
  → Code structure
```

---

## Invokes Agent

**@ArchitectureAgent** will handle this command with the following context:

```markdown
Task: Create implementation plan
Feature: ${user_input}
Requirements: ${requirements}

Deliverables:
1. High-level approach and architecture
2. Step-by-step implementation plan
3. File structure and organization
4. Dependencies and integration points
5. Testing strategy
6. Security considerations
7. Performance implications
8. Deployment requirements
9. Estimated effort
10. Risk assessment

Output Format:
- Executive summary
- Detailed step-by-step plan
- Task checklist
- Code structure
- Trade-offs and decisions
```

---

## Plan Output Example

### Example 1: Authentication Feature

**Input**:
```bash
/plan "Add user authentication with OAuth2 (Google)"
```

**Output**:
```markdown
# Implementation Plan: OAuth2 Authentication (Google)

## Executive Summary

**Goal**: Implement Google OAuth2 authentication for user login
**Approach**: Use Passport.js with Google OAuth2 strategy
**Effort**: Medium (3-5 days)
**Risk Level**: Low-Medium

---

## Requirements Analysis

### Functional Requirements
- Users can sign up using Google account
- Users can log in using Google account
- Store user profile info (name, email, avatar)
- Generate JWT token after successful authentication

### Non-Functional Requirements
- Secure token storage
- Session management
- HTTPS required
- Google API credentials management

---

## Architecture Overview

```
┌─────────────┐
│   Client    │
│  (React)    │
└──────┬──────┘
       │ 1. Click "Sign in with Google"
       ↓
┌─────────────┐
│  /auth/     │
│  google     │ 2. Redirect to Google
└──────┬──────┘
       │
       ↓ 3. User authorizes
┌─────────────┐
│   Google    │
│   OAuth2    │
└──────┬──────┘
       │ 4. Callback with code
       ↓
┌─────────────┐
│  /auth/     │
│  callback   │ 5. Exchange code for token
└──────┬──────┘
       │ 6. Create/update user
       ↓
┌─────────────┐
│  Database   │
└──────┬──────┘
       │ 7. Generate JWT
       ↓
┌─────────────┐
│   Client    │
│  (logged in)│
└─────────────┘
```

---

## Implementation Steps

### Phase 1: Setup (Day 1)

#### Step 1: Install Dependencies
```bash
npm install passport passport-google-oauth20 jsonwebtoken
npm install --save-dev @types/passport @types/passport-google-oauth20
```

#### Step 2: Google Cloud Setup
- [ ] Create project in Google Cloud Console
- [ ] Enable Google+ API
- [ ] Create OAuth2 credentials
- [ ] Configure authorized redirect URIs
- [ ] Store credentials in environment variables

**Files to create**:
- `.env.example` - Document required variables

**Environment variables needed**:
```
GOOGLE_CLIENT_ID=your_client_id
GOOGLE_CLIENT_SECRET=your_client_secret
GOOGLE_CALLBACK_URL=http://localhost:3000/auth/google/callback
JWT_SECRET=your_jwt_secret
```

---

### Phase 2: Backend Implementation (Day 2-3)

#### Step 3: Database Schema
**File**: `src/db/migrations/20260122_create_users.sql`
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  google_id VARCHAR(255) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255),
  avatar_url TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  last_login TIMESTAMP
);

CREATE INDEX idx_users_google_id ON users(google_id);
CREATE INDEX idx_users_email ON users(email);
```

#### Step 4: User Model
**File**: `src/models/User.ts`
```typescript
export interface User {
  id: string;
  googleId: string;
  email: string;
  name: string;
  avatarUrl?: string;
  createdAt: Date;
  lastLogin?: Date;
}

export class UserRepository {
  async findByGoogleId(googleId: string): Promise<User | null>
  async findByEmail(email: string): Promise<User | null>
  async create(userData: Partial<User>): Promise<User>
  async update(id: string, userData: Partial<User>): Promise<User>
}
```

#### Step 5: Passport Configuration
**File**: `src/auth/passport.ts`
```typescript
import passport from 'passport';
import { Strategy as GoogleStrategy } from 'passport-google-oauth20';

passport.use(new GoogleStrategy({
  clientID: process.env.GOOGLE_CLIENT_ID,
  clientSecret: process.env.GOOGLE_CLIENT_SECRET,
  callbackURL: process.env.GOOGLE_CALLBACK_URL
}, async (accessToken, refreshToken, profile, done) => {
  // Find or create user
  // Return user object
}));
```

#### Step 6: Authentication Routes
**File**: `src/routes/auth.ts`
```typescript
router.get('/auth/google',
  passport.authenticate('google', { scope: ['profile', 'email'] })
);

router.get('/auth/google/callback',
  passport.authenticate('google', { session: false }),
  (req, res) => {
    // Generate JWT
    // Send token to client
  }
);
```

#### Step 7: JWT Token Generation
**File**: `src/auth/jwt.ts`
```typescript
export function generateToken(user: User): string {
  return jwt.sign(
    { userId: user.id, email: user.email },
    process.env.JWT_SECRET,
    { expiresIn: '7d' }
  );
}

export function verifyToken(token: string): TokenPayload {
  return jwt.verify(token, process.env.JWT_SECRET);
}
```

#### Step 8: Authentication Middleware
**File**: `src/middleware/auth.ts`
```typescript
export async function authenticate(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }

  try {
    const payload = verifyToken(token);
    req.user = await getUserById(payload.userId);
    next();
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
}
```

---

### Phase 3: Frontend Implementation (Day 3-4)

#### Step 9: Login Button Component
**File**: `src/components/GoogleLoginButton.tsx`
```typescript
export function GoogleLoginButton() {
  const handleLogin = () => {
    window.location.href = '/api/auth/google';
  };

  return (
    <button onClick={handleLogin}>
      Sign in with Google
    </button>
  );
}
```

#### Step 10: Handle OAuth Callback
**File**: `src/pages/AuthCallback.tsx`
```typescript
export function AuthCallback() {
  useEffect(() => {
    // Extract token from URL or query params
    const token = new URLSearchParams(window.location.search).get('token');

    if (token) {
      // Store token
      localStorage.setItem('auth_token', token);

      // Redirect to dashboard
      navigate('/dashboard');
    }
  }, []);

  return <LoadingSpinner />;
}
```

#### Step 11: Auth Context
**File**: `src/contexts/AuthContext.tsx`
```typescript
export function AuthProvider({ children }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const token = localStorage.getItem('auth_token');
    if (token) {
      fetchCurrentUser(token).then(setUser);
    }
    setLoading(false);
  }, []);

  return (
    <AuthContext.Provider value={{ user, loading }}>
      {children}
    </AuthContext.Provider>
  );
}
```

---

### Phase 4: Testing (Day 4-5)

#### Step 12: Unit Tests
**Files**:
- `tests/auth/passport.test.ts`
- `tests/auth/jwt.test.ts`
- `tests/models/User.test.ts`

#### Step 13: Integration Tests
**File**: `tests/integration/auth.test.ts`
```typescript
describe('OAuth2 Authentication Flow', () => {
  it('should authenticate user with Google', async () => {
    // Mock Google OAuth response
    // Test full flow
  });
});
```

#### Step 14: E2E Tests
**File**: `e2e/auth/google-login.spec.ts`
```typescript
test('user can login with Google', async ({ page }) => {
  // Test actual Google login flow
});
```

---

### Phase 5: Security & Deployment (Day 5)

#### Step 15: Security Review
- [ ] HTTPS enforced
- [ ] CSRF protection
- [ ] Token storage secure (httpOnly cookies recommended)
- [ ] Rate limiting on auth endpoints
- [ ] Input validation

#### Step 16: Documentation
**Files**:
- `docs/authentication.md` - User guide
- `docs/oauth-setup.md` - Developer setup guide
- Update `README.md`

#### Step 17: Deployment
- [ ] Add environment variables to production
- [ ] Update Google OAuth redirect URIs for production
- [ ] Deploy to staging
- [ ] Manual testing on staging
- [ ] Deploy to production

---

## File Structure

```
src/
├── auth/
│   ├── passport.ts       (Passport configuration)
│   ├── jwt.ts            (JWT utilities)
│   └── strategies/
│       └── google.ts     (Google OAuth2 strategy)
├── middleware/
│   └── auth.ts           (Authentication middleware)
├── models/
│   └── User.ts           (User model and repository)
├── routes/
│   └── auth.ts           (Authentication routes)
├── components/
│   └── GoogleLoginButton.tsx
├── contexts/
│   └── AuthContext.tsx
└── pages/
    └── AuthCallback.tsx

tests/
├── auth/
│   ├── passport.test.ts
│   └── jwt.test.ts
└── integration/
    └── auth.test.ts

e2e/
└── auth/
    └── google-login.spec.ts

docs/
├── authentication.md
└── oauth-setup.md
```

---

## Dependencies

### Direct Dependencies
- `passport` - Authentication middleware
- `passport-google-oauth20` - Google OAuth2 strategy
- `jsonwebtoken` - JWT token generation

### Prerequisites
- Google Cloud Console account
- Database with users table
- HTTPS in production

---

## Security Considerations

### ✅ Must Do
1. **HTTPS Only**: OAuth requires HTTPS in production
2. **Secure Token Storage**: Use httpOnly cookies (not localStorage)
3. **CSRF Protection**: Implement CSRF tokens
4. **Rate Limiting**: Limit login attempts
5. **Token Expiry**: Short-lived access tokens (15 min)
6. **Refresh Tokens**: Implement refresh token rotation

### ⚠️ Common Pitfalls
- Storing tokens in localStorage (vulnerable to XSS)
- Not validating Google tokens server-side
- Hardcoding credentials
- Not handling token expiry
- Missing redirect URI validation

---

## Performance Considerations

- **Database**: Add indexes on googleId and email
- **Caching**: Cache user data after login (Redis)
- **Token Validation**: Fast JWT verification (< 5ms)
- **OAuth Flow**: ~2-3 seconds for full flow

---

## Testing Strategy

### Unit Tests (Target: 90% coverage)
- JWT generation and validation
- User model CRUD operations
- Passport strategy logic

### Integration Tests
- Full OAuth flow (mocked)
- Token exchange
- User creation/update

### E2E Tests (Priority 1)
- Complete login flow
- Logout flow
- Token expiry handling

---

## Deployment Checklist

- [ ] Environment variables configured
- [ ] Google OAuth credentials for production
- [ ] Database migration applied
- [ ] HTTPS certificate valid
- [ ] Redirect URIs updated
- [ ] Rate limiting configured
- [ ] Monitoring and alerts set up
- [ ] Documentation updated

---

## Effort Estimation

| Phase | Tasks | Estimated Time |
|-------|-------|----------------|
| Setup | 2 tasks | 4 hours |
| Backend | 6 tasks | 12 hours |
| Frontend | 3 tasks | 8 hours |
| Testing | 3 tasks | 8 hours |
| Security & Deploy | 3 tasks | 4 hours |
| **Total** | **17 tasks** | **36 hours (4.5 days)** |

---

## Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Google API downtime | Low | High | Add fallback auth method |
| Token theft | Medium | High | Use httpOnly cookies, short expiry |
| Rate limiting | Low | Medium | Monitor usage, upgrade plan if needed |
| Migration issues | Medium | Medium | Test thoroughly in staging first |

---

## Trade-Offs & Decisions

### Decision 1: JWT vs Sessions
**Chosen**: JWT
**Rationale**: Stateless, works better for API-first architecture
**Trade-off**: Harder to revoke tokens immediately

### Decision 2: Token Storage
**Chosen**: httpOnly cookies (recommended)
**Alternative**: localStorage (simpler but less secure)
**Rationale**: Better security, protects against XSS

### Decision 3: User Creation
**Chosen**: Auto-create user on first login
**Alternative**: Separate signup flow
**Rationale**: Better UX, Google already verified email

---

## Next Steps

After approval:
1. Create feature branch: `feature/oauth-google`
2. Start with Phase 1 (Setup)
3. Implement incrementally, commit after each step
4. Create PR after Phase 3 (core functionality)
5. Add tests in separate PR if needed
6. Deploy to staging for testing
7. Deploy to production after approval

---

## Questions to Resolve

Before starting implementation:
1. Do we need to support multiple OAuth providers (GitHub, Facebook)?
2. Should we allow traditional email/password alongside OAuth?
3. What user data do we need from Google (just email or full profile)?
4. Do we need refresh token rotation?
5. What's the token expiry policy (7 days, 30 days)?

**Ready to proceed? Type "APPROVED" to begin implementation.**
```

---

## When to Use This Command

**Use /plan when**:
- ✅ Starting new features
- ✅ Making architectural changes
- ✅ Planning refactors
- ✅ Before major changes
- ✅ When approach is unclear

**Benefits**:
- Prevents over-engineering
- Identifies issues early
- Creates clear roadmap
- Improves estimates
- Reduces rework

---

## Related Commands

- `/review-queue` - Get plan reviewed before implementation
- `/test-run` - Run tests after implementation
- `/security-scan` - Security review after implementation

---

**Remember**: Planning prevents problems. Take time to plan before coding.
