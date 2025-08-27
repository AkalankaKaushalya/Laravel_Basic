# Laravel Model සම්පූර්ණ මාර්ගෝපදේශය

## 📚 Model කියන්නේ මොකක්ද?

**Model** කියන්නේ Database Table එකක් සම්බන්ධ වූ PHP class එකක්. මෙය **MVC Pattern** එකේ **M** කොටස.

**සරල උදාහරණයකින්:**
```
Database Table: users
Laravel Model: User.php
```

Model එක හරහා ඔයාට පුළුවන්:
- Database වලට data insert කරන්න
- Data update කරන්න  
- Data delete කරන්න
- Data retrieve කරන්න
- Table relationships handle කරන්න

---

## 🏗️ Model Structure විස්තරය

### 1️⃣ Basic Model Structure

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    use HasFactory, Notifiable;

    // Table Configuration
    protected $table = 'users';
    protected $primaryKey = 'user_id';
    public $incrementing = true;
    protected $keyType = 'int';

    // Mass Assignment
    protected $fillable = [
        'user_name',
        'user_email',
        'user_mobile',
        'password',
        'user_role',
        'user_status',
    ];

    // Hidden Fields
    protected $hidden = [
        'password',
        'remember_token',
    ];

    // Data Casting
    protected $casts = [
        'email_verified_at' => 'datetime',
        'user_status' => 'boolean',
    ];
}
```

---

## 🔧 Model Properties විස්තර

### 📋 Table Configuration

#### `$table` Property
```php
protected $table = 'users';
```
**අර්ථය:** Model එක කවර database table එකට connect වෙනවාද කියලා දන්වනවා.

**Default Behavior:** Laravel automatically model name එකෙන් table name හදනවා:
- `User` model → `users` table
- `JobPost` model → `job_posts` table

**කවදා use කරන්නද?** Table name එක convention අනුව නැති වෙලාවට:
```php
// Table name: tbl_users (not users)
protected $table = 'tbl_users';
```

#### `$primaryKey` Property
```php
protected $primaryKey = 'user_id';
```
**අර්ථය:** Primary key column name එක define කරනවා.

**Default:** Laravel `id` කියලා assume කරනවා.

**Example:**
```php
// Default behavior
$user = User::find(1); // WHERE id = 1

// Custom primary key
protected $primaryKey = 'user_id';
$user = User::find(1); // WHERE user_id = 1
```

#### `$incrementing` සහ `$keyType`
```php
public $incrementing = true;  // Auto-increment enabled
protected $keyType = 'int';   // Primary key type
```

**වෙනත් Options:**
```php
// UUID primary key
protected $keyType = 'string';
public $incrementing = false;
```

---

### 🛡️ Mass Assignment Protection

#### `$fillable` Array
```php
protected $fillable = [
    'user_name',
    'user_email',
    'user_mobile',
    'password',
];
```

**අර්ථය:** Mass assignment වලදී use කරන්න පුළුවන් fields.

**Mass Assignment කියන්නේ මොකක්ද?**
```php
// Mass Assignment - Array එකෙන් data insert කරනවා
User::create([
    'user_name' => 'Kasun',
    'user_email' => 'kasun@example.com',
    'password' => bcrypt('123456'),
]);

// Individual Assignment
$user = new User();
$user->user_name = 'Kasun';
$user->user_email = 'kasun@example.com';
$user->save();
```

#### `$guarded` Array (Alternative)
```php
protected $guarded = ['id', 'created_at', 'updated_at'];
```
**අර්ථය:** Mass assignment වලදී use කරන්න බෑ fields.

**හොඳම Approach:** `$fillable` use කරන්න, secure වනකමක්.

---

### 🙈 Hidden Fields

#### `$hidden` Array
```php
protected $hidden = [
    'password',
    'remember_token',
];
```

**කවදා use වෙනවාද?**
```php
$user = User::find(1);

// JSON response වලට convert කරන වෙලාවට
return response()->json($user);

// Output: password සහ remember_token නැතුව JSON එක එනවා
{
    "user_id": 1,
    "user_name": "Kasun",
    "user_email": "kasun@example.com"
    // password, remember_token fields නැහැ
}
```

#### `$visible` Array (Alternative)
```php
protected $visible = ['user_name', 'user_email'];
```
**අර්ථය:** JSON response වල show වෙන fields පමණක්.

---

### 🔄 Data Casting

#### `$casts` Array
```php
protected $casts = [
    'email_verified_at' => 'datetime',
    'user_status' => 'boolean',
    'preferences' => 'array',
    'salary' => 'decimal:2',
];
```

**Cast Types:**
- `datetime` → Carbon instance
- `boolean` → true/false
- `array` → PHP array
- `json` → JSON format
- `decimal:2` → Decimal වල places 2

**Examples:**
```php
$user = User::find(1);

// Datetime casting
echo $user->email_verified_at->format('Y-m-d'); // 2024-01-15

// Boolean casting  
if ($user->user_status) {
    echo "User is active";
}

// Array casting
$user->preferences = ['theme' => 'dark', 'lang' => 'si'];
$user->save();
// Database වල JSON format වලට save වෙනවා
```

---

## 🔗 Relationships (සම්බන්ධතා)

### 1️⃣ One-to-Many (එක් User කෙනෙක්ට Jobs ගොඩාක්)

**User Model:**
```php
public function jobPosts()
{
    return $this->hasMany(JobPost::class, 'posted_by', 'user_id');
}
```

**JobPost Model:**
```php
public function user()
{
    return $this->belongsTo(User::class, 'posted_by', 'user_id');
}
```

**Usage:**
```php
$user = User::find(1);

// User එකේ සියලුම job posts
foreach ($user->jobPosts as $job) {
    echo $job->title;
}

// Job post එකේ user
$job = JobPost::find(1);
echo $job->user->user_name;
```

### 2️⃣ One-to-One (එක් User කෙනෙක්ට එක් Profile එකක්)

**User Model:**
```php
public function profile()
{
    return $this->hasOne(UserProfile::class, 'user_id', 'user_id');
}
```

**UserProfile Model:**
```php
public function user()
{
    return $this->belongsTo(User::class, 'user_id', 'user_id');
}
```

**Usage:**
```php
$user = User::find(1);
echo $user->profile->bio;

// Profile හරහා user access කරනවා
$profile = UserProfile::find(1);
echo $profile->user->user_name;
```

### 3️⃣ Many-to-Many (Users සහ Roles)

**User Model:**
```php
public function roles()
{
    return $this->belongsToMany(Role::class, 'user_roles', 'user_id', 'role_id');
}
```

**Role Model:**
```php
public function users()
{
    return $this->belongsToMany(User::class, 'user_roles', 'role_id', 'user_id');
}
```

**Pivot Table:** `user_roles`
```sql
CREATE TABLE user_roles (
    id INT PRIMARY KEY,
    user_id INT,
    role_id INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
```

**Usage:**
```php
$user = User::find(1);

// User එකේ roles
foreach ($user->roles as $role) {
    echo $role->role_name;
}

// Role assign කරනවා
$user->roles()->attach([1, 2, 3]);

// Role remove කරනවා  
$user->roles()->detach([2]);
```

---

## ✨ Accessors සහ Mutators

### Accessors (Data Read කරන වෙලාවට modify)

```php
// User name එක always uppercase වලට convert
public function getUserNameAttribute($value)
{
    return strtoupper($value);
}

// Full name accessor (database column එකක් නෙමෙයි)
public function getFullNameAttribute()
{
    return $this->first_name . ' ' . $this->last_name;
}
```

**Usage:**
```php
$user = User::find(1);
echo $user->user_name;  // "KASUN" (uppercase converted)
echo $user->full_name;  // "Kasun Perera" (combined)
```

### Mutators (Data Save කරන වෙලාවට modify)

```php
// Password එක always bcrypt
public function setPasswordAttribute($value)
{
    $this->attributes['password'] = bcrypt($value);
}

// User name එක lowercase save
public function setUserNameAttribute($value)
{
    $this->attributes['user_name'] = strtolower($value);
}
```

**Usage:**
```php
$user = new User();
$user->password = '123456';  // Database වල bcrypt වෙලා save වෙනවා
$user->user_name = 'KASUN';  // Database වල 'kasun' save වෙනවා
$user->save();
```

---

## 🔍 Query Scopes

### Local Scopes (Reusable Filters)

```php
// Active users පමණක්
public function scopeActive($query)
{
    return $query->where('user_status', 1);
}

// Specific role users
public function scopeRole($query, $role)
{
    return $query->where('user_role', $role);
}

// Recent users (අලුතින් register වූ)
public function scopeRecent($query, $days = 30)
{
    return $query->where('created_at', '>=', now()->subDays($days));
}
```

**Usage:**
```php
// Active users සියල්ල
$activeUsers = User::active()->get();

// Admin role users
$admins = User::role('admin')->get();

// Recent active admins
$recentAdmins = User::active()
                   ->role('admin')
                   ->recent(7)
                   ->get();
```

### Global Scopes

```php
// සියලුම queries වලට automatically apply
protected static function booted()
{
    static::addGlobalScope('active', function ($query) {
        $query->where('user_status', 1);
    });
}
```

---

## 🗑️ Soft Deletes

### Setup

**Migration:**
```php
public function up()
{
    Schema::table('users', function (Blueprint $table) {
        $table->softDeletes(); // deleted_at column එකක් add වෙනවා
    });
}
```

**Model:**
```php
use Illuminate\Database\Eloquent\SoftDeletes;

class User extends Authenticatable
{
    use HasFactory, Notifiable, SoftDeletes;
}
```

### Usage

```php
// Delete කරනවා (actually deleted_at timestamp set කරනවා)
$user = User::find(1);
$user->delete();

// Soft deleted records include කරන්න
$users = User::withTrashed()->get();

// Soft deleted records පමණක්
$deletedUsers = User::onlyTrashed()->get();

// Restore කරනවා
$user = User::withTrashed()->find(1);
$user->restore();

// Permanently delete
$user->forceDelete();
```

---

## ⚡ Advanced Eloquent Features

### 1️⃣ Mass Updates

```php
// Multiple records update at once
User::where('user_role', 'user')
    ->where('created_at', '<', now()->subYear())
    ->update(['user_status' => 0]);

// Increment/Decrement
User::where('user_id', 1)->increment('login_count');
User::where('user_id', 1)->decrement('credits', 5);
```

### 2️⃣ Chunking (Large Data Processing)

```php
// Memory efficient processing
User::chunk(100, function ($users) {
    foreach ($users as $user) {
        // Send email, process data, etc.
        Mail::to($user->user_email)->send(new NewsletterMail());
    }
});
```

### 3️⃣ Model Events

```php
protected static function booted()
{
    // User create වෙන වෙලාවට
    static::creating(function ($user) {
        $user->user_role = $user->user_role ?? 'user';
        $user->user_status = 1;
    });

    // User update වෙන වෙලාවට
    static::updating(function ($user) {
        $user->updated_by = auth()->id();
    });

    // User delete වෙන වෙලාවට
    static::deleting(function ($user) {
        // Related data cleanup
        $user->jobPosts()->delete();
    });
}
```

### 4️⃣ Attribute Casting Advanced

```php
protected $casts = [
    'skills' => 'array',
    'settings' => 'json',
    'salary_range' => 'encrypted',
    'is_verified' => 'boolean',
    'joined_date' => 'date:Y-m-d',
];
```

### 5️⃣ Custom Collections

```php
// UserCollection.php
class UserCollection extends Collection
{
    public function activeUsers()
    {
        return $this->where('user_status', 1);
    }
    
    public function adminUsers()
    {
        return $this->where('user_role', 'admin');
    }
}

// User Model වල
public function newCollection(array $models = [])
{
    return new UserCollection($models);
}

// Usage
$users = User::all();
$activeAdmins = $users->activeUsers()->adminUsers();
```

---

## 🧪 Testing Support

### Factory Usage

**UserFactory.php:**
```php
public function definition()
{
    return [
        'user_name' => fake()->name(),
        'user_email' => fake()->unique()->safeEmail(),
        'password' => bcrypt('password'),
        'user_role' => 'user',
        'user_status' => 1,
    ];
}

// States define කරනවා
public function admin()
{
    return $this->state([
        'user_role' => 'admin',
    ]);
}

public function inactive()
{
    return $this->state([
        'user_status' => 0,
    ]);
}
```

**Usage:**
```php
// Basic factory usage
$user = User::factory()->create();

// Multiple users
$users = User::factory()->count(10)->create();

// With states
$admin = User::factory()->admin()->create();
$inactiveUsers = User::factory()->inactive()->count(5)->create();

// With custom attributes
$user = User::factory()->create([
    'user_name' => 'Test User',
    'user_email' => 'test@example.com',
]);
```

---

## 📊 Summary Table

| Feature | Purpose | Example Usage |
|---------|---------|---------------|
| `$table` | Database table name specify | `protected $table = 'tbl_users';` |
| `$primaryKey` | Custom primary key | `protected $primaryKey = 'user_id';` |
| `$fillable` | Mass assignment allowed fields | `User::create([...])` |
| `$hidden` | JSON response වල hide fields | `['password', 'token']` |
| `$casts` | Data type conversion | `'created_at' => 'datetime'` |
| Relationships | Table connections | `hasMany()`, `belongsTo()` |
| Scopes | Reusable query filters | `User::active()->get()` |
| Accessors/Mutators | Data manipulation | `getUserNameAttribute()` |
| Soft Deletes | Recoverable deletions | `$user->delete(); $user->restore();` |
| Events | Lifecycle hooks | `creating()`, `updating()` |

---

## 🎯 Best Practices

1. **නම්කරණය:** Model names singular (`User` not `Users`)
2. **Fillable:** සැම විටම `$fillable` define කරන්න security වලට
3. **Relationships:** Proper foreign key naming (`user_id`, `post_id`)
4. **Validation:** Model වල business logic validations
5. **Scopes:** Common queries වලට scopes use කරන්න
6. **Events:** Data consistency වලට model events use කරන්න
7. **Testing:** Factory classes හදන්න testing වලට

---

මෙම guide එක follow කරලා ඔයාට Laravel Models මහල්ලන්ගේ level වල use කරන්න පුළුවන්! 🚀