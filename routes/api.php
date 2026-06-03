<?php

use App\Http\Controllers\Api\AuthApiController;
use App\Http\Controllers\Api\CartApiController;
use App\Http\Controllers\Api\OrderApiController;
use App\Http\Controllers\Api\ProductApiController;
use Illuminate\Support\Facades\Route;

// Public routes
Route::prefix('v1')->group(function () {

    // Auth
    Route::post('/register', [AuthApiController::class, 'register']);
    Route::post('/login',    [AuthApiController::class, 'login']);

    // Products (public)
    Route::get('/products',          [ProductApiController::class, 'index']);
    Route::get('/products/{product:slug}', [ProductApiController::class, 'show']);
    Route::get('/categories',        [ProductApiController::class, 'categories']);

    // Protected routes
    Route::middleware('auth:sanctum')->group(function () {

        // Auth
        Route::get('/me',     [AuthApiController::class, 'me']);
        Route::post('/logout',[AuthApiController::class, 'logout']);

        // Cart
        Route::get('/cart',              [CartApiController::class, 'index']);
        Route::post('/cart/{product}',   [CartApiController::class, 'add']);
        Route::patch('/cart/{cart}',     [CartApiController::class, 'update']);
        Route::delete('/cart/{cart}',    [CartApiController::class, 'remove']);

        // Orders
        Route::get('/orders',            [OrderApiController::class, 'index']);
        Route::post('/orders',           [OrderApiController::class, 'store']);
        Route::get('/orders/{order}',    [OrderApiController::class, 'show']);
    });
});
