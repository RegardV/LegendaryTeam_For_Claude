# 📐 Coding Style Rules

## Purpose
Mandatory coding style and formatting rules for all Legendary Team agents to ensure consistency.

---

## General Rules

### 1. **Use TypeScript**
```typescript
// ✅ REQUIRED
function add(a: number, b: number): number {
  return a + b;
}

// ❌ FORBIDDEN (JavaScript without types)
function add(a, b) {
  return a + b;
}
```

**Rule**: All new code MUST be written in TypeScript with explicit types.

---

### 2. **No `any` Type**
```typescript
// ❌ FORBIDDEN
function process(data: any) {
  return data.value;
}

// ✅ REQUIRED
interface Data {
  value: string;
}

function process(data: Data) {
  return data.value;
}

// ✅ ACCEPTABLE (if type is truly unknown)
function process(data: unknown) {
  if (typeof data === 'object' && data !== null && 'value' in data) {
    return (data as Data).value;
  }
  throw new Error('Invalid data');
}
```

**Rule**: The `any` type is FORBIDDEN. Use proper types or `unknown` with type guards.

---

### 3. **Use Const by Default**
```typescript
// ❌ FORBIDDEN
let name = 'John';
let age = 30;

// ✅ REQUIRED
const name = 'John';
const age = 30;

// ✅ ACCEPTABLE (when reassignment is needed)
let count = 0;
count++;
```

**Rule**: Use `const` by default. Only use `let` when reassignment is necessary. NEVER use `var`.

---

### 4. **Descriptive Variable Names**
```typescript
// ❌ FORBIDDEN
const u = await getUser();
const d = new Date();
const x = calculate(y);

// ✅ REQUIRED
const user = await getUser();
const currentDate = new Date();
const total = calculate(items);
```

**Rule**: Variable names MUST be descriptive. Abbreviations are only acceptable for:
- Loop indices: `i`, `j`, `k`
- Common abbreviations: `id`, `url`, `api`, `db`

---

### 5. **Function Naming**
```typescript
// ✅ REQUIRED - Use verbs for functions
async function getUser(id: string): Promise<User> { }
function calculateTotal(items: Item[]): number { }
function isValid(input: string): boolean { }

// ✅ REQUIRED - Boolean functions start with is/has/can/should
function isActive(user: User): boolean { }
function hasPermission(user: User, action: string): boolean { }
function canEdit(user: User, resource: Resource): boolean { }
```

**Rule**: Function names MUST be verbs. Boolean-returning functions MUST start with `is`, `has`, `can`, or `should`.

---

### 6. **Small Functions**
```typescript
// ❌ FORBIDDEN - Function too long (> 50 lines)
function processOrder(order: Order) {
  // 100 lines of code...
}

// ✅ REQUIRED - Break into smaller functions
function processOrder(order: Order) {
  validateOrder(order);
  const payment = processPayment(order);
  const shipment = createShipment(order);
  sendConfirmationEmail(order, payment, shipment);
  return { payment, shipment };
}

function validateOrder(order: Order) {
  // Validation logic
}

function processPayment(order: Order): Payment {
  // Payment logic
}

function createShipment(order: Order): Shipment {
  // Shipment logic
}
```

**Rule**: Functions SHOULD be < 50 lines. If longer, break into smaller functions.

---

### 7. **Arrow Functions for Callbacks**
```typescript
// ❌ DISCOURAGED
items.map(function(item) {
  return item.name;
});

// ✅ REQUIRED
items.map(item => item.name);

// ✅ REQUIRED (multiple statements)
items.map(item => {
  const name = item.name.toUpperCase();
  return name;
});
```

**Rule**: Use arrow functions for callbacks and short functions.

---

### 8. **Avoid Nested Ternaries**
```typescript
// ❌ FORBIDDEN
const status = user.isActive
  ? user.isPremium
    ? 'premium'
    : 'active'
  : 'inactive';

// ✅ REQUIRED
function getUserStatus(user: User): string {
  if (!user.isActive) return 'inactive';
  if (user.isPremium) return 'premium';
  return 'active';
}

const status = getUserStatus(user);
```

**Rule**: Nested ternaries are FORBIDDEN. Use if/else or a function.

---

### 9. **Early Returns**
```typescript
// ❌ DISCOURAGED - Deep nesting
function processUser(user: User) {
  if (user.isActive) {
    if (user.hasPermission) {
      if (user.isVerified) {
        // Process user
        return result;
      }
    }
  }
  return null;
}

// ✅ REQUIRED - Early returns
function processUser(user: User) {
  if (!user.isActive) return null;
  if (!user.hasPermission) return null;
  if (!user.isVerified) return null;

  // Process user
  return result;
}
```

**Rule**: Use early returns to reduce nesting.

---

### 10. **Destructuring**
```typescript
// ❌ DISCOURAGED
function displayUser(user: User) {
  console.log(user.name);
  console.log(user.email);
  console.log(user.role);
}

// ✅ REQUIRED
function displayUser(user: User) {
  const { name, email, role } = user;
  console.log(name);
  console.log(email);
  console.log(role);
}

// ✅ REQUIRED - In function parameters
function displayUser({ name, email, role }: User) {
  console.log(name);
  console.log(email);
  console.log(role);
}
```

**Rule**: Use destructuring when accessing multiple properties.

---

## TypeScript Specific Rules

### 11. **Explicit Return Types**
```typescript
// ❌ FORBIDDEN
function getUser(id: string) {
  return db.users.findById(id);
}

// ✅ REQUIRED
function getUser(id: string): Promise<User | null> {
  return db.users.findById(id);
}
```

**Rule**: Functions MUST have explicit return types.

---

### 12. **Interface over Type for Objects**
```typescript
// ❌ DISCOURAGED
type User = {
  id: string;
  name: string;
};

// ✅ REQUIRED
interface User {
  id: string;
  name: string;
}

// ✅ ACCEPTABLE (for unions, intersections, primitives)
type Status = 'active' | 'inactive';
type ID = string | number;
```

**Rule**: Use `interface` for object shapes. Use `type` for unions, intersections, and primitives.

---

### 13. **Strict Null Checks**
```typescript
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "strictNullChecks": true
  }
}

// ✅ REQUIRED - Handle null/undefined
function getUser(id: string): User | null {
  const user = db.users.findById(id);
  return user ?? null;
}

function displayUser(user: User | null) {
  if (!user) {
    console.log('No user found');
    return;
  }

  console.log(user.name); // TypeScript knows user is not null
}
```

**Rule**: Strict mode MUST be enabled. Always handle null/undefined cases.

---

## Formatting Rules

### 14. **Indentation: 2 Spaces**
```typescript
// ✅ REQUIRED
function example() {
  if (condition) {
    doSomething();
  }
}
```

**Rule**: Use 2 spaces for indentation (not tabs).

---

### 15. **Line Length: 100 Characters Max**
```typescript
// ❌ FORBIDDEN
const message = `This is a very long string that exceeds the 100 character limit and should be broken into multiple lines`;

// ✅ REQUIRED
const message = `This is a very long string that exceeds the 100 character limit ` +
  `and should be broken into multiple lines`;

// OR
const message = `
  This is a very long string that exceeds the 100 character limit
  and should be broken into multiple lines
`.trim();
```

**Rule**: Lines SHOULD NOT exceed 100 characters.

---

### 16. **Semicolons Required**
```typescript
// ❌ FORBIDDEN
const name = 'John'
const age = 30

// ✅ REQUIRED
const name = 'John';
const age = 30;
```

**Rule**: All statements MUST end with semicolons.

---

### 17. **Single Quotes for Strings**
```typescript
// ❌ FORBIDDEN
const name = "John";

// ✅ REQUIRED
const name = 'John';

// ✅ ACCEPTABLE (template literals)
const message = `Hello, ${name}`;
```

**Rule**: Use single quotes for strings. Use template literals for interpolation.

---

### 18. **Trailing Commas**
```typescript
// ✅ REQUIRED
const obj = {
  name: 'John',
  age: 30,  // Trailing comma
};

const arr = [
  'item1',
  'item2',  // Trailing comma
];
```

**Rule**: Use trailing commas in multi-line objects and arrays.

---

## Comment Rules

### 19. **Comment the Why, Not the What**
```typescript
// ❌ BAD - Obvious comment
// Increment counter by 1
counter++;

// ✅ GOOD - Explains why
// Use exponential backoff to avoid overwhelming the API during high traffic
const delay = Math.min(1000 * Math.pow(2, retryCount), 30000);
```

**Rule**: Only comment non-obvious logic. Explain WHY, not WHAT.

---

### 20. **JSDoc for Public APIs**
```typescript
/**
 * Calculates the total price of items in the cart
 * @param items - Array of cart items
 * @param discountCode - Optional discount code to apply
 * @returns Total price after discounts
 */
export function calculateTotal(
  items: CartItem[],
  discountCode?: string
): number {
  // Implementation
}
```

**Rule**: Public functions MUST have JSDoc comments.

---

## Import Rules

### 21. **Organize Imports**
```typescript
// ✅ REQUIRED - Order: external, internal, types
import { useState, useEffect } from 'react';
import express from 'express';

import { UserService } from './services/user';
import { calculateTotal } from './utils/math';

import type { User } from './types/user';
import type { Order } from './types/order';
```

**Rule**: Group imports in order: external libraries, internal modules, types.

---

### 22. **Named Exports Preferred**
```typescript
// ❌ DISCOURAGED
export default function calculateTotal() { }

// ✅ REQUIRED
export function calculateTotal() { }

// Import:
import { calculateTotal } from './utils';
```

**Rule**: Prefer named exports over default exports (except for React components).

---

## React-Specific Rules

### 23. **Functional Components**
```typescript
// ❌ FORBIDDEN
class UserCard extends React.Component {
  render() {
    return <div>{this.props.name}</div>;
  }
}

// ✅ REQUIRED
interface UserCardProps {
  name: string;
}

export function UserCard({ name }: UserCardProps) {
  return <div>{name}</div>;
}
```

**Rule**: Use functional components with hooks. Class components are FORBIDDEN.

---

### 24. **Props Interface**
```typescript
// ❌ FORBIDDEN
export function UserCard({ name, email, age }) {
  return <div>...</div>;
}

// ✅ REQUIRED
interface UserCardProps {
  name: string;
  email: string;
  age: number;
}

export function UserCard({ name, email, age }: UserCardProps) {
  return <div>...</div>;
}
```

**Rule**: All React components MUST have typed props.

---

## Async/Await Rules

### 25. **Prefer Async/Await over Promises**
```typescript
// ❌ DISCOURAGED
function loadUser(id: string) {
  return fetchUser(id)
    .then(user => processUser(user))
    .then(processed => saveUser(processed))
    .catch(error => handleError(error));
}

// ✅ REQUIRED
async function loadUser(id: string): Promise<void> {
  try {
    const user = await fetchUser(id);
    const processed = await processUser(user);
    await saveUser(processed);
  } catch (error) {
    handleError(error);
  }
}
```

**Rule**: Use async/await instead of Promise chains.

---

## Formatting Tools

### Required Configuration

**Prettier** (`.prettierrc`):
```json
{
  "semi": true,
  "singleQuote": true,
  "trailingComma": "es5",
  "printWidth": 100,
  "tabWidth": 2,
  "arrowParens": "avoid"
}
```

**ESLint** (`.eslintrc`):
```json
{
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended"
  ],
  "rules": {
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/explicit-function-return-type": "error"
  }
}
```

---

**REMEMBER**: Consistent style makes code easier to read and maintain. Follow these rules on every commit.

**Last Updated**: 2026-01-22
**Maintained By**: Legendary Team Agents
