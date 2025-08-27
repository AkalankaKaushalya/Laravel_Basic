# Laravel Controllers සම්පූර්ණ මාර්ගෝපදේශය

## 📚 Controller කියන්නේ මොකක්ද?

**Controller** කියන්නේ **MVC Pattern** එකේ **C** කොටස. මේක traffic cop කෙනෙක් වගේ:

```
User Request → Routes → Controller → Model/Database → View → Response
```

**Controller එක කරන්නේ:**
- HTTP requests handle කරනවා
- Business logic process කරනවා  
- Models සම්බන්ධ කරනවා
- Views return කරනවා
- Validation handle කරනවා

**සරල Example:**
```php
// UserController.php
public function index()
{
    $users = User::all();           // Model වලින් data
    return view('users.index', [    // View එකට data pass
        'users' => $users
    ]);
}
```

---

## 🏗️ Controller Types

### 1️⃣ Basic Controller

```php
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;

class UserController extends Controller
{
    public function index()
    {
        $users = User::all();
        return view('users.index', compact('users'));
    }

    public function show($id)
    {
        $user = User::find($id);
        return view('users.show', compact('user'));
    }
}
```

### 2️⃣ Resource Controller (CRUD Operations)

```php
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;

class UserController extends Controller
{
    /**
     * Display a listing of the resource.
     * GET /users
     */
    public function index()
    {
        $users = User::paginate(10);
        return view('users.index', compact('users'));
    }

    /**
     * Show the form for creating a new resource.
     * GET /users/create
     */
    public function create()
    {
        return view('users.create');
    }

    /**
     * Store a newly created resource in storage.
     * POST /users
     */
    public function store(Request $request)
    {
        $validatedData = $request->validate([
            'user_name' => 'required|string|max:255',
            'user_email' => 'required|email|unique:users',
            'password' => 'required|min:8',
        ]);

        $validatedData['password'] = bcrypt($validatedData['password']);
        
        $user = User::create($validatedData);

        return redirect()->route('users.index')
                        ->with('success', 'User created successfully!');
    }

    /**
     * Display the specified resource.
     * GET /users/{id}
     */
    public function show(User $user)
    {
        return view('users.show', compact('user'));
    }

    /**
     * Show the form for editing the specified resource.
     * GET /users/{id}/edit
     */
    public function edit(User $user)
    {
        return view('users.edit', compact('user'));
    }

    /**
     * Update the specified resource in storage.
     * PUT/PATCH /users/{id}
     */
    public function update(Request $request, User $user)
    {
        $validatedData = $request->validate([
            'user_name' => 'required|string|max:255',
            'user_email' => 'required|email|unique:users,user_email,' . $user->user_id . ',user_id',
        ]);

        $user->update($validatedData);

        return redirect()->route('users.index')
                        ->with('success', 'User updated successfully!');
    }

    /**
     * Remove the specified resource from storage.
     * DELETE /users/{id}
     */
    public function destroy(User $user)
    {
        $user->delete();

        return redirect()->route('users.index')
                        ->with('success', 'User deleted successfully!');
    }
}
```

### 3️⃣ API Resource Controller

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use App\Http\Resources\UserResource;

class UserController extends Controller
{
    public function index()
    {
        $users = User::paginate(10);
        return UserResource::collection($users);
    }

    public function store(Request $request)
    {
        $validatedData = $request->validate([
            'user_name' => 'required|string|max:255',
            'user_email' => 'required|email|unique:users',
            'password' => 'required|min:8',
        ]);

        $validatedData['password'] = bcrypt($validatedData['password']);
        $user = User::create($validatedData);

        return new UserResource($user);
    }

    public function show(User $user)
    {
        return new UserResource($user);
    }

    public function update(Request $request, User $user)
    {
        $validatedData = $request->validate([
            'user_name' => 'sometimes|string|max:255',
            'user_email' => 'sometimes|email|unique:users,user_email,' . $user->user_id . ',user_id',
        ]);

        $user->update($validatedData);

        return new UserResource($user);
    }

    public function destroy(User $user)
    {
        $user->delete();

        return response()->json([
            'message' => 'User deleted successfully'
        ], 200);
    }
}
```

---

## 🛠️ Controller Creation Commands

### Artisan Commands

```bash
# Basic Controller
php artisan make:controller UserController

# Resource Controller (CRUD methods සහිතව)
php artisan make:controller UserController --resource

# API Resource Controller (API methods සහිතව)
php artisan make:controller Api/UserController --api

# Model සහිතව Resource Controller
php artisan make:controller UserController --resource --model=User

# Invokable Controller (single action)
php artisan make:controller ShowProfileController --invokable
```

### Generated File Structure

```php
// Invokable Controller Example
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class ShowProfileController extends Controller
{
    /**
     * Handle the incoming request.
     */
    public function __invoke(Request $request)
    {
        return view('profile.show');
    }
}
```

---

## 📝 Request Handling විස්තර

### 1️⃣ Request Object Usage

```php
public function store(Request $request)
{
    // Input values get කරනවා
    $name = $request->input('user_name');
    $email = $request->input('user_email', 'default@example.com'); // default value
    
    // All inputs
    $allData = $request->all();
    
    // Only specific inputs
    $userData = $request->only(['user_name', 'user_email']);
    
    // Except specific inputs
    $dataExceptPassword = $request->except(['password']);
    
    // Check if input exists
    if ($request->has('user_name')) {
        // Process name
    }
    
    // Check if input is filled (not empty)
    if ($request->filled('user_email')) {
        // Process email
    }
    
    // File uploads
    if ($request->hasFile('profile_image')) {
        $file = $request->file('profile_image');
        $path = $file->store('profile_images', 'public');
    }
}
```

### 2️⃣ Validation විස්තර

```php
public function store(Request $request)
{
    // Basic validation
    $validatedData = $request->validate([
        'user_name' => 'required|string|max:255',
        'user_email' => 'required|email|unique:users',
        'password' => 'required|min:8|confirmed',
        'user_mobile' => 'nullable|string|regex:/^[0-9]{10}$/',
        'user_age' => 'integer|between:18,65',
        'profile_image' => 'sometimes|image|mimes:jpeg,png,jpg|max:2048',
    ]);

    // Custom error messages
    $validatedData = $request->validate([
        'user_name' => 'required|string|max:255',
        'user_email' => 'required|email|unique:users',
    ], [
        'user_name.required' => 'නම අනිවාර්යයි',
        'user_email.email' => 'වලංගු email address එකක් දෙන්න',
        'user_email.unique' => 'මෙම email address එක දැනටමත් භාවිතා වේ',
    ]);

    // Process validated data
    User::create($validatedData);
}
```

### 3️⃣ Form Request Classes (Advanced Validation)

**Create Form Request:**
```bash
php artisan make:request StoreUserRequest
```

**StoreUserRequest.php:**
```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreUserRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return auth()->check(); // User logged in නම් allow
    }

    /**
     * Get the validation rules that apply to the request.
     */
    public function rules(): array
    {
        return [
            'user_name' => 'required|string|max:255',
            'user_email' => 'required|email|unique:users,user_email',
            'password' => 'required|min:8|confirmed',
            'user_mobile' => 'nullable|string|regex:/^[0-9]{10}$/',
            'user_role' => 'required|in:admin,user,moderator',
        ];
    }

    /**
     * Custom error messages
     */
    public function messages(): array
    {
        return [
            'user_name.required' => 'නම අනිවාර්යයි',
            'user_email.email' => 'වලංගු email address එකක් දෙන්න',
            'user_email.unique' => 'මෙම email address එක දැනටමත් භාවිතා වේ',
            'password.min' => 'Password අක්ෂර 8 කට වඩා වැඩි විය යුතුයි',
            'password.confirmed' => 'Password confirmation නොගැලපේ',
        ];
    }

    /**
     * Get custom attributes for validator errors.
     */
    public function attributes(): array
    {
        return [
            'user_email' => 'ඊමේල් ලිපිනය',
            'user_name' => 'පරිශීලක නම',
        ];
    }

    /**
     * Prepare the data for validation.
     */
    protected function prepareForValidation(): void
    {
        $this->merge([
            'user_name' => trim($this->user_name),
            'user_email' => strtolower($this->user_email),
        ]);
    }
}
```

**Controller වල Usage:**
```php
use App\Http\Requests\StoreUserRequest;

public function store(StoreUserRequest $request)
{
    // Validation දැනටමත් pass වෙලා, validated data use කරන්න පුළුවන්
    $validatedData = $request->validated();
    
    $user = User::create($validatedData);

    return redirect()->route('users.index')
                    ->with('success', 'User created successfully!');
}
```

---

## 🔄 Response Types

### 1️⃣ View Responses

```php
public function index()
{
    $users = User::all();
    
    // Basic view return
    return view('users.index');
    
    // With data
    return view('users.index', compact('users'));
    
    // With array data
    return view('users.index', [
        'users' => $users,
        'title' => 'All Users'
    ]);
    
    // With additional data
    return view('users.index')
           ->with('users', $users)
           ->with('total', $users->count());
}
```

### 2️⃣ JSON Responses

```php
public function apiIndex()
{
    $users = User::all();
    
    // Simple JSON
    return response()->json($users);
    
    // With status code
    return response()->json($users, 200);
    
    // Custom structure
    return response()->json([
        'status' => 'success',
        'data' => $users,
        'total' => $users->count(),
        'message' => 'Users retrieved successfully'
    ]);
    
    // Error response
    return response()->json([
        'status' => 'error',
        'message' => 'Users not found'
    ], 404);
}
```

### 3️⃣ Redirect Responses

```php
public function store(Request $request)
{
    // Process data...
    
    // Redirect to route
    return redirect()->route('users.index');
    
    // Redirect with success message
    return redirect()->route('users.index')
                    ->with('success', 'User created successfully!');
    
    // Redirect with error message
    return redirect()->back()
                    ->with('error', 'Something went wrong!')
                    ->withInput(); // Keep form data
    
    // Redirect with validation errors
    return redirect()->back()
                    ->withErrors($validator)
                    ->withInput();
}
```

### 4️⃣ Download Responses

```php
public function downloadCv(User $user)
{
    $filePath = storage_path('app/cvs/' . $user->user_cv);
    
    // Check if file exists
    if (!file_exists($filePath)) {
        return redirect()->back()
                        ->with('error', 'File not found!');
    }
    
    // Download file
    return response()->download($filePath, $user->user_name . '_CV.pdf');
}

public function exportUsers()
{
    $users = User::all();
    $csvData = $this->generateCSV($users);
    
    return response($csvData)
           ->header('Content-Type', 'text/csv')
           ->header('Content-Disposition', 'attachment; filename="users.csv"');
}
```

---

## 🛡️ Middleware Usage

### Controller Constructor වල Middleware

```php
<?php

namespace App\Http\Controllers;

class UserController extends Controller
{
    public function __construct()
    {
        // All methods වලට authentication required
        $this->middleware('auth');
        
        // Specific methods වලට middleware
        $this->middleware('admin')->only(['create', 'store', 'destroy']);
        
        // Except specific methods
        $this->middleware('verified')->except(['show', 'index']);
        
        // Custom middleware
        $this->middleware('check.user.status');
    }
}
```

### Method Level Middleware

```php
public function sensitiveAction(Request $request)
{
    // Inline middleware check
    $this->middleware('admin');
    
    // Process sensitive action
    return view('admin.sensitive');
}
```

---

## 📊 Advanced Controller Patterns

### 1️⃣ Service Pattern

**UserService.php:**
```php
<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Hash;

class UserService
{
    public function createUser(array $data)
    {
        $data['password'] = Hash::make($data['password']);
        $data['user_status'] = 1; // Active by default
        
        $user = User::create($data);
        
        // Send welcome email
        Mail::to($user->user_email)->send(new WelcomeEmail($user));
        
        return $user;
    }
    
    public function updateUser(User $user, array $data)
    {
        // Update password if provided
        if (isset($data['password'])) {
            $data['password'] = Hash::make($data['password']);
        }
        
        $user->update($data);
        
        return $user;
    }
    
    public function deleteUser(User $user)
    {
        // Clean up related data
        $user->jobPosts()->delete();
        $user->applications()->delete();
        
        return $user->delete();
    }
}
```

**Controller with Service:**
```php
<?php

namespace App\Http\Controllers;

use App\Services\UserService;
use App\Http\Requests\StoreUserRequest;

class UserController extends Controller
{
    protected $userService;
    
    public function __construct(UserService $userService)
    {
        $this->userService = $userService;
        $this->middleware('auth');
    }
    
    public function store(StoreUserRequest $request)
    {
        try {
            $user = $this->userService->createUser($request->validated());
            
            return redirect()->route('users.index')
                           ->with('success', 'User created successfully!');
        } catch (\Exception $e) {
            return redirect()->back()
                           ->with('error', 'Failed to create user: ' . $e->getMessage())
                           ->withInput();
        }
    }
}
```

### 2️⃣ Repository Pattern

**UserRepository.php:**
```php
<?php

namespace App\Repositories;

use App\Models\User;

class UserRepository
{
    protected $model;
    
    public function __construct(User $user)
    {
        $this->model = $user;
    }
    
    public function getAllUsers($perPage = 10)
    {
        return $this->model->with('profile')
                          ->orderBy('created_at', 'desc')
                          ->paginate($perPage);
    }
    
    public function getActiveUsers()
    {
        return $this->model->where('user_status', 1)
                          ->orderBy('user_name')
                          ->get();
    }
    
    public function findByEmail($email)
    {
        return $this->model->where('user_email', $email)->first();
    }
    
    public function createUser(array $data)
    {
        return $this->model->create($data);
    }
    
    public function updateUser($id, array $data)
    {
        return $this->model->where('user_id', $id)->update($data);
    }
    
    public function deleteUser($id)
    {
        return $this->model->where('user_id', $id)->delete();
    }
}
```

### 3️⃣ Trait Usage for Common Functions

**ResponseTrait.php:**
```php
<?php

namespace App\Traits;

trait ResponseTrait
{
    protected function successResponse($data = null, $message = 'Success', $statusCode = 200)
    {
        return response()->json([
            'status' => 'success',
            'message' => $message,
            'data' => $data
        ], $statusCode);
    }
    
    protected function errorResponse($message = 'Error', $statusCode = 400, $errors = null)
    {
        $response = [
            'status' => 'error',
            'message' => $message
        ];
        
        if ($errors) {
            $response['errors'] = $errors;
        }
        
        return response()->json($response, $statusCode);
    }
}
```

**Controller with Trait:**
```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Traits\ResponseTrait;
use App\Models\User;

class UserController extends Controller
{
    use ResponseTrait;
    
    public function index()
    {
        $users = User::all();
        
        return $this->successResponse($users, 'Users retrieved successfully');
    }
    
    public function show($id)
    {
        $user = User::find($id);
        
        if (!$user) {
            return $this->errorResponse('User not found', 404);
        }
        
        return $this->successResponse($user);
    }
}
```

---

## 🎯 Error Handling

### 1️⃣ Try-Catch Blocks

```php
public function store(Request $request)
{
    try {
        // Validation
        $validatedData = $request->validate([
            'user_name' => 'required|string|max:255',
            'user_email' => 'required|email|unique:users',
        ]);
        
        // Database operation
        $user = User::create($validatedData);
        
        // Success response
        return redirect()->route('users.index')
                        ->with('success', 'User created successfully!');
                        
    } catch (\Illuminate\Validation\ValidationException $e) {
        // Validation errors
        return redirect()->back()
                        ->withErrors($e->validator)
                        ->withInput();
                        
    } catch (\Exception $e) {
        // General errors
        \Log::error('User creation failed: ' . $e->getMessage());
        
        return redirect()->back()
                        ->with('error', 'Something went wrong. Please try again.')
                        ->withInput();
    }
}
```

### 2️⃣ Custom Exception Handling

```php
public function show($id)
{
    try {
        $user = User::findOrFail($id); // Throws ModelNotFoundException
        
        return view('users.show', compact('user'));
        
    } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
        
        return redirect()->route('users.index')
                        ->with('error', 'User not found!');
    }
}
```

---

## 📱 RESTful API Best Practices

### API Response Structure

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;

class UserController extends Controller
{
    /**
     * GET /api/users
     */
    public function index(Request $request)
    {
        $perPage = $request->get('per_page', 15);
        $users = User::with('profile')
                    ->when($request->search, function ($query) use ($request) {
                        $query->where('user_name', 'like', '%' . $request->search . '%')
                              ->orWhere('user_email', 'like', '%' . $request->search . '%');
                    })
                    ->when($request->status, function ($query) use ($request) {
                        $query->where('user_status', $request->status);
                    })
                    ->orderBy('created_at', 'desc')
                    ->paginate($perPage);

        return response()->json([
            'status' => 'success',
            'data' => [
                'users' => $users->items(),
                'pagination' => [
                    'current_page' => $users->currentPage(),
                    'per_page' => $users->perPage(),
                    'total' => $users->total(),
                    'last_page' => $users->lastPage(),
                    'has_more_pages' => $users->hasMorePages(),
                ]
            ],
            'message' => 'Users retrieved successfully'
        ]);
    }

    /**
     * POST /api/users
     */
    public function store(Request $request)
    {
        $validatedData = $request->validate([
            'user_name' => 'required|string|max:255',
            'user_email' => 'required|email|unique:users',
            'password' => 'required|min:8',
            'user_role' => 'required|in:admin,user,moderator',
        ]);

        $validatedData['password'] = bcrypt($validatedData['password']);
        $user = User::create($validatedData);

        return response()->json([
            'status' => 'success',
            'data' => $user,
            'message' => 'User created successfully'
        ], 201);
    }

    /**
     * GET /api/users/{id}
     */
    public function show($id)
    {
        $user = User::with(['profile', 'jobPosts'])->find($id);

        if (!$user) {
            return response()->json([
                'status' => 'error',
                'message' => 'User not found'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => $user,
            'message' => 'User retrieved successfully'
        ]);
    }

    /**
     * PUT /api/users/{id}
     */
    public function update(Request $request, $id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'status' => 'error',
                'message' => 'User not found'
            ], 404);
        }

        $validatedData = $request->validate([
            'user_name' => 'sometimes|string|max:255',
            'user_email' => 'sometimes|email|unique:users,user_email,' . $id . ',user_id',
            'user_role' => 'sometimes|in:admin,user,moderator',
        ]);

        $user->update($validatedData);

        return response()->json([
            'status' => 'success',
            'data' => $user->fresh(),
            'message' => 'User updated successfully'
        ]);
    }

    /**
     * DELETE /api/users/{id}
     */
    public function destroy($id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'status' => 'error',
                'message' => 'User not found'
            ], 404);
        }

        $user->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'User deleted successfully'
        ]);
    }
}
```

---

## 🧪 Testing Controllers

### Feature Tests

```php
<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

class UserControllerTest extends TestCase
{
    use RefreshDatabase;

    /** @test */
    public function user_can_view_users_index()
    {
        $user = User::factory()->create();
        
        $response = $this->actingAs($user)
                        ->get(route('users.index'));

        $response->assertStatus(200)
                ->assertViewIs('users.index');
    }

    /** @test */
    public function user_can_create_new_user()
    {
        $admin = User::factory()->admin()->create();
        
        $userData = [
            'user_name' => 'Test User',
            'user_email' => 'test@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
        ];

        $response = $this->actingAs($admin)
                        ->post(route('users.store'), $userData);

        $response->assertRedirect(route('users.index'))
                ->assertSessionHas('success');
        
        $this->assertDatabaseHas('users', [
            'user_email' => 'test@example.com'
        ]);
    }

    /** @test */
    public function user_creation_requires_valid_email()
    {
        $admin = User::factory()->admin()->create();
        
        $response = $this->actingAs($admin)
                        ->post(route('users.store'), [
                            'user_name' => 'Test User',
                            'user_email' => 'invalid-email',
                            'password' => 'password123',
                        ]);

        $response->assertSessionHasErrors(['user_email']);
    }
}
```

---

## 📊 Performance Optimization

### 1️⃣ Eager Loading

```php
public function index()
{
    // N+1 Problem avoid කරන්න
    $users = User::with(['profile', 'jobPosts.company'])
                ->orderBy('created_at', 'desc')
                ->paginate(10);

    return view('users.index', compact('users'));
}

public function show(User $user)
{
    // Load relationships when needed
    $user->load(['profile', 'jobPosts' => function ($query) {
        $query->latest()->limit(5);
    }]);

    return view('users.show', compact('user'));
}
```

### 2️⃣ Query Optimization

```php
public function dashboard()
{
    // Single queries වලට combine කරනවා
    $stats = [
        'total_users' => User::count(),
        'active_users' => User::where('user_status', 1)->count(),
        'new_users_today' => User::whereDate('created_at', today())->count(),
        'recent_users' => User::with('profile')
                             ->latest()
                             ->limit(5)
                             ->get(),
    ];

    return view('dashboard', compact('stats'));
}
```

### 3️⃣ Caching

```php
use Illuminate\Support\Facades\Cache;

public function popularUsers()
{
    $users = Cache::remember('popular_users', 3600, function () {
        return User::withCount('jobPosts')
                  ->orderBy('job_posts_count', 'desc')
                  ->limit(10)
                  ->get();
    });

    return view('users.popular', compact('users'));
}
```

---

## 📋 Summary Table

| Feature | Purpose | Example Usage |
|---------|---------|---------------|
| **Resource Controller** | CRUD operations | `php artisan make:controller --resource` |
| **Form Request** | Advanced validation | `StoreUserRequest $request` |
| **Route Model Binding** | Automatic model injection | `public function show(User $user)` |
| **Middleware** | Access control | `$this->middleware('auth')` |
| **Service Pattern** | Business logic separation | `UserService::createUser()` |
| **Repository Pattern** | Data access layer | `UserRepository::getAllUsers()` |
| **Error Handling** | Exception management | `try-catch blocks` |
| **API Resources** | JSON response formatting | `UserResource::collection()` |
| **Validation** | Data integrity | `$request->validate()` |
| **Response Types** | Different output formats | `view()`, `json()`, `redirect()` |

---

## 🎯 Best Practices

### 1️⃣ Controller Organization
```php
// ✅ Good - Single responsibility
class UserController extends Controller
{
    // Only user-related actions
    public function index() { }
    public function show() { }
    public function store() { }
}

// ❌ Bad - Mixed responsibilities
class UserController extends Controller
{
    public function index() { }
    public function sendEmail() { }      // Should be in EmailController
    public function generateReport() { } // Should be in ReportController
}
```

### 2️⃣ Method Naming
```php
// ✅ Good - Clear, descriptive names
public function index()           // List all
public function show($id)         // Show one
public function create()          // Show create form
public function store()           // Save new
public function edit($id)         // Show edit form  
public function update($id)       // Save changes
public function destroy($id)      // Delete

// Custom actions
public function activate(User $user)
public function deactivate(User $user)
public function exportCsv()
```

### 3️⃣ Dependency Injection
```php
// ✅ Good - Constructor injection
class UserController extends Controller
{
    public function __construct(
        protected UserService $userService,
        protected EmailService $emailService
    ) {}
    
    public function store(StoreUserRequest $request)
    {
        $user = $this->userService->create($request->validated());
        $this->emailService->sendWelcome($user);
        
        return redirect()->route('users.index');
    }
}

// ❌ Bad - Direct instantiation
public function store(Request $request)
{
    $service = new UserService(); // Hard to test
    $user = $service->create($request->all());
}
```

### 4️⃣ Return Type Consistency
```php
// ✅ Good - Consistent responses
public function store(Request $request)
{
    // Always return redirect for form submissions
    return redirect()->route('users.index')
                    ->with('success', 'User created!');
}

public function apiStore(Request $request)
{
    // Always return JSON for API
    return response()->json([
        'status' => 'success',
        'data' => $user
    ], 201);
}
```

### 5️⃣ Error Handling
```php
// ✅ Good - Proper error handling
public function show($id)
{
    $user = User::find($id);
    
    if (!$user) {
        abort(404, 'User not found');
    }
    
    return view('users.show', compact('user'));
}

// Or with route model binding
public function show(User $user) // Automatically throws 404
{
    return view('users.show', compact('user'));
}
```

---

## 🔧 Advanced Techniques

### 1️⃣ Controller Inheritance

```php
// BaseController.php
<?php

namespace App\Http\Controllers;

abstract class BaseController extends Controller
{
    protected $model;
    protected $viewPath;
    protected $routeName;

    public function index()
    {
        $items = $this->model::paginate(10);
        
        return view("{$this->viewPath}.index", [
            'items' => $items
        ]);
    }

    public function show($id)
    {
        $item = $this->model::findOrFail($id);
        
        return view("{$this->viewPath}.show", [
            'item' => $item
        ]);
    }

    public function destroy($id)
    {
        $item = $this->model::findOrFail($id);
        $item->delete();

        return redirect()->route("{$this->routeName}.index")
                        ->with('success', 'Item deleted successfully!');
    }
}

// UserController.php
<?php

namespace App\Http\Controllers;

use App\Models\User;

class UserController extends BaseController
{
    protected $model = User::class;
    protected $viewPath = 'users';
    protected $routeName = 'users';

    // Only implement custom methods
    public function activate(User $user)
    {
        $user->update(['user_status' => 1]);
        
        return redirect()->back()
                        ->with('success', 'User activated!');
    }
}
```

### 2️⃣ Action-Based Controllers

```php
// Single Action Controllers
<?php

namespace App\Http\Controllers\User;

use App\Http\Controllers\Controller;

class ActivateUserController extends Controller
{
    public function __invoke(User $user)
    {
        $user->update(['user_status' => 1]);
        
        // Log activity
        activity()
            ->performedOn($user)
            ->log('User activated');
        
        return redirect()->back()
                        ->with('success', 'User activated successfully!');
    }
}

// Usage in routes
Route::patch('/users/{user}/activate', ActivateUserController::class)
     ->name('users.activate');
```

### 3️⃣ Controller Events

```php
<?php

namespace App\Http\Controllers;

class UserController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
        
        // Controller events
        $this->beforeFilter();
        $this->afterFilter();
    }
    
    protected function beforeFilter()
    {
        // Run before each action
        view()->share('currentUser', auth()->user());
    }
    
    protected function afterFilter()
    {
        // Run after each action
        // Log user activity, clear cache, etc.
    }

    public function store(Request $request)
    {
        // Trigger event before processing
        event('user.creating', $request->all());
        
        $user = User::create($request->validated());
        
        // Trigger event after processing
        event('user.created', $user);
        
        return redirect()->route('users.index');
    }
}
```

### 4️⃣ Dynamic Controller Actions

```php
<?php

namespace App\Http\Controllers;

class UserController extends Controller
{
    public function updateStatus(Request $request, User $user, $status)
    {
        $allowedStatuses = ['active', 'inactive', 'banned', 'pending'];
        
        if (!in_array($status, $allowedStatuses)) {
            abort(400, 'Invalid status');
        }
        
        $statusMap = [
            'active' => 1,
            'inactive' => 0,
            'banned' => 2,
            'pending' => 3
        ];
        
        $user->update([
            'user_status' => $statusMap[$status],
            'status_updated_by' => auth()->id(),
            'status_updated_at' => now()
        ]);
        
        return redirect()->back()
                        ->with('success', "User status changed to {$status}");
    }
}

// Route
Route::patch('/users/{user}/status/{status}', [UserController::class, 'updateStatus'])
     ->name('users.status');
```

---

## 🚀 Real-World Examples

### 1️⃣ Job Portal User Management

```php
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\JobPost;
use App\Http\Requests\StoreUserRequest;
use App\Services\UserService;
use App\Exports\UsersExport;
use Illuminate\Http\Request;

class UserManagementController extends Controller
{
    public function __construct(
        protected UserService $userService
    ) {
        $this->middleware('auth');
        $this->middleware('admin')->except(['index', 'show']);
    }

    /**
     * Display paginated users with filters
     */
    public function index(Request $request)
    {
        $users = User::query()
            ->with(['profile', 'jobPosts'])
            ->when($request->search, function ($query) use ($request) {
                $query->where(function ($q) use ($request) {
                    $q->where('user_name', 'like', "%{$request->search}%")
                      ->orWhere('user_email', 'like', "%{$request->search}%");
                });
            })
            ->when($request->role, function ($query) use ($request) {
                $query->where('user_role', $request->role);
            })
            ->when($request->status !== null, function ($query) use ($request) {
                $query->where('user_status', $request->status);
            })
            ->orderBy($request->get('sort', 'created_at'), $request->get('order', 'desc'))
            ->paginate(15)
            ->withQueryString();

        $stats = [
            'total' => User::count(),
            'active' => User::where('user_status', 1)->count(),
            'inactive' => User::where('user_status', 0)->count(),
            'new_today' => User::whereDate('created_at', today())->count(),
        ];

        return view('admin.users.index', compact('users', 'stats'));
    }

    /**
     * Show user profile with activity
     */
    public function show(User $user)
    {
        $user->load([
            'profile',
            'jobPosts' => function ($query) {
                $query->withCount('applications')->latest()->limit(5);
            },
            'applications.jobPost'
        ]);

        $activityLog = activity()
            ->causedBy($user)
            ->latest()
            ->limit(10)
            ->get();

        return view('admin.users.show', compact('user', 'activityLog'));
    }

    /**
     * Store new user with role assignment
     */
    public function store(StoreUserRequest $request)
    {
        try {
            $user = $this->userService->createUserWithProfile($request->validated());
            
            // Send welcome email based on role
            if ($request->user_role === 'company') {
                $this->userService->sendCompanyWelcomeEmail($user);
            } else {
                $this->userService->sendJobSeekerWelcomeEmail($user);
            }
            
            activity()
                ->causedBy(auth()->user())
                ->performedOn($user)
                ->log('User created by admin');

            return redirect()->route('admin.users.index')
                           ->with('success', 'User created and welcome email sent!');
                           
        } catch (\Exception $e) {
            logger()->error('User creation failed', [
                'admin_id' => auth()->id(),
                'data' => $request->validated(),
                'error' => $e->getMessage()
            ]);
            
            return redirect()->back()
                           ->with('error', 'Failed to create user. Please try again.')
                           ->withInput();
        }
    }

    /**
     * Bulk actions for multiple users
     */
    public function bulkAction(Request $request)
    {
        $request->validate([
            'action' => 'required|in:activate,deactivate,delete,change_role',
            'user_ids' => 'required|array|min:1',
            'user_ids.*' => 'exists:users,user_id',
            'new_role' => 'required_if:action,change_role|in:admin,user,company,moderator'
        ]);

        $users = User::whereIn('user_id', $request->user_ids);
        $count = $users->count();

        switch ($request->action) {
            case 'activate':
                $users->update(['user_status' => 1]);
                $message = "{$count} users activated successfully";
                break;

            case 'deactivate':
                $users->update(['user_status' => 0]);
                $message = "{$count} users deactivated successfully";
                break;

            case 'delete':
                $users->delete();
                $message = "{$count} users deleted successfully";
                break;

            case 'change_role':
                $users->update(['user_role' => $request->new_role]);
                $message = "{$count} users role changed to {$request->new_role}";
                break;
        }

        // Log bulk action
        activity()
            ->causedBy(auth()->user())
            ->withProperties([
                'action' => $request->action,
                'user_count' => $count,
                'user_ids' => $request->user_ids
            ])
            ->log("Bulk action performed: {$request->action}");

        return redirect()->back()->with('success', $message);
    }

    /**
     * Export users data
     */
    public function export(Request $request)
    {
        $request->validate([
            'format' => 'required|in:csv,xlsx,pdf',
            'filters' => 'sometimes|array'
        ]);

        try {
            $filename = 'users_' . now()->format('Y-m-d_H-i-s') . '.' . $request->format;
            
            return (new UsersExport($request->filters ?? []))
                ->download($filename);
                
        } catch (\Exception $e) {
            return redirect()->back()
                           ->with('error', 'Export failed: ' . $e->getMessage());
        }
    }

    /**
     * User statistics dashboard
     */
    public function statistics()
    {
        $stats = [
            'registrations' => [
                'today' => User::whereDate('created_at', today())->count(),
                'week' => User::whereBetween('created_at', [
                    now()->startOfWeek(), 
                    now()->endOfWeek()
                ])->count(),
                'month' => User::whereMonth('created_at', now()->month)->count(),
                'year' => User::whereYear('created_at', now()->year)->count(),
            ],
            'by_role' => User::selectRaw('user_role, count(*) as count')
                           ->groupBy('user_role')
                           ->pluck('count', 'user_role')
                           ->toArray(),
            'activity' => [
                'active_today' => User::whereDate('last_login_at', today())->count(),
                'active_week' => User::where('last_login_at', '>=', now()->subWeek())->count(),
                'never_logged_in' => User::whereNull('last_login_at')->count(),
            ],
            'recent_registrations' => User::with('profile')
                                        ->latest()
                                        ->limit(10)
                                        ->get(),
        ];

        return view('admin.users.statistics', compact('stats'));
    }
}
```

### 2️⃣ File Upload Controller

```php
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use App\Models\User;

class FileUploadController extends Controller
{
    public function uploadProfileImage(Request $request, User $user)
    {
        $request->validate([
            'profile_image' => 'required|image|mimes:jpeg,png,jpg|max:2048', // 2MB max
        ]);

        try {
            // Delete old profile image if exists
            if ($user->user_profile && Storage::disk('public')->exists($user->user_profile)) {
                Storage::disk('public')->delete($user->user_profile);
            }

            // Store new image
            $imagePath = $request->file('profile_image')->store('profile_images', 'public');
            
            // Update user record
            $user->update(['user_profile' => $imagePath]);

            // Create thumbnail
            $this->createThumbnail($imagePath);

            return response()->json([
                'status' => 'success',
                'message' => 'Profile image updated successfully',
                'image_url' => Storage::url($imagePath)
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to upload image: ' . $e->getMessage()
            ], 500);
        }
    }

    public function uploadCV(Request $request, User $user)
    {
        $request->validate([
            'cv_file' => 'required|mimes:pdf,doc,docx|max:5120', // 5MB max
        ]);

        try {
            // Delete old CV if exists
            if ($user->user_cv && Storage::disk('private')->exists($user->user_cv)) {
                Storage::disk('private')->delete($user->user_cv);
            }

            // Store CV in private disk (not publicly accessible)
            $cvPath = $request->file('cv_file')->store('cvs', 'private');
            
            // Update user record
            $user->update([
                'user_cv' => $cvPath,
                'cv_uploaded_at' => now()
            ]);

            // Log activity
            activity()
                ->performedOn($user)
                ->log('CV uploaded');

            return redirect()->back()
                           ->with('success', 'CV uploaded successfully');

        } catch (\Exception $e) {
            return redirect()->back()
                           ->with('error', 'Failed to upload CV: ' . $e->getMessage())
                           ->withInput();
        }
    }

    public function downloadCV(User $user)
    {
        if (!$user->user_cv || !Storage::disk('private')->exists($user->user_cv)) {
            abort(404, 'CV not found');
        }

        // Check permissions (only user themselves or admin)
        if (auth()->id() !== $user->user_id && !auth()->user()->isAdmin()) {
            abort(403, 'Unauthorized access');
        }

        $filename = $user->user_name . '_CV.' . pathinfo($user->user_cv, PATHINFO_EXTENSION);
        
        // Log download activity
        activity()
            ->causedBy(auth()->user())
            ->performedOn($user)
            ->log('CV downloaded');

        return Storage::disk('private')->download($user->user_cv, $filename);
    }

    private function createThumbnail($imagePath)
    {
        // Implementation for creating image thumbnail
        // You can use Image intervention or other libraries
    }

    /**
     * Multiple file upload
     */
    public function uploadMultiple(Request $request)
    {
        $request->validate([
            'files.*' => 'required|file|mimes:jpeg,png,jpg,pdf,doc,docx|max:2048',
        ]);

        $uploadedFiles = [];
        
        foreach ($request->file('files') as $file) {
            $path = $file->store('uploads', 'public');
            $uploadedFiles[] = [
                'original_name' => $file->getClientOriginalName(),
                'stored_path' => $path,
                'size' => $file->getSize(),
                'mime_type' => $file->getMimeType(),
            ];
        }

        return response()->json([
            'status' => 'success',
            'message' => count($uploadedFiles) . ' files uploaded successfully',
            'files' => $uploadedFiles
        ]);
    }
}
```

---

## 🎯 Final Best Practices Summary

1. **Single Responsibility**: එක controller එකක් එක responsibility එකක් පමණක්
2. **RESTful Routes**: Standard REST conventions follow කරන්න
3. **Form Requests**: Validation logic separate කරන්න
4. **Service Classes**: Business logic controllers වලින් separate කරන්න
5. **Error Handling**: Proper try-catch blocks සහ user-friendly messages
6. **Security**: Authentication, authorization, සහ input validation
7. **Performance**: Eager loading, caching, query optimization
8. **Testing**: Feature tests සහ unit tests write කරන්න
9. **Documentation**: Clear comments සහ method documentation
10. **Consistency**: Team coding standards follow කරන්න

---

මෙම comprehensive guide එක follow කරලා ඔයාට Laravel Controllers professional level වලට use කරන්න පුළුවන්! Controllers වල advanced patterns, real-world examples, සහ best practices සියල්ලම මෙහි ඇතුළත් වේ. 🚀

අමතර questions තියෙනවා නම් අහන්න!