<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Customer\CustomerOrderController;
use App\Http\Controllers\Customer\CustomerNotificationController;
use App\Http\Controllers\Api\AuthApiController;
use App\Http\Controllers\Api\ProductRentalApiController;
use App\Http\Controllers\Api\OrderRentalApiController;

// Midtrans callback
Route::post('/midtrans/callback', [CustomerOrderController::class, 'midtransCallback']);

/*
|--------------------------------------------------------------------------
| Mobile Flutter API Routes
|--------------------------------------------------------------------------
*/
Route::prefix('mobile')->group(function () {
    // Auth
    Route::post('/login', [AuthApiController::class, 'login']);
    Route::post('/register', [AuthApiController::class, 'register']);

    // Public Product & Categories
    Route::get('/products', [ProductRentalApiController::class, 'index']);
    Route::get('/products/{id}', [ProductRentalApiController::class, 'show']);
    Route::get('/categories', [ProductRentalApiController::class, 'categories']);

    // Protected Routes
    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/me', [AuthApiController::class, 'me']);
        Route::post('/logout', [AuthApiController::class, 'logout']);

        // Orders
        Route::get('/orders', [OrderRentalApiController::class, 'index']);
        Route::get('/orders/{id}', [OrderRentalApiController::class, 'show']);
        Route::post('/orders', [OrderRentalApiController::class, 'store']);
    });
});
