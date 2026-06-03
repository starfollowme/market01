<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthApiController extends Controller
{
    /**
     * Helper untuk normalisasi nomor HP
     */
    private function normalizePhone($phone)
    {
        $phone = preg_replace('/[^0-9]/', '', $phone);
        if (substr($phone, 0, 1) === '0') {
            $phone = '62' . substr($phone, 1);
        } elseif (substr($phone, 0, 2) !== '62') {
            $phone = '62' . $phone;
        }
        return $phone;
    }

    public function login(Request $request)
    {
        $request->validate([
            'phone'    => 'required|string',
            'password' => 'required|string',
        ]);

        $normalizedPhone = $this->normalizePhone($request->phone);
        $user = User::where('phone', $normalizedPhone)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Nomor atau password salah'
            ], 401);
        }

        // Cek verifikasi phone
        if (in_array($user->role, ['customer', 'seller']) && !$user->phone_verified_at) {
            return response()->json([
                'success' => false,
                'message' => 'Nomor belum diverifikasi. Silakan verifikasi terlebih dahulu di web.'
            ], 403);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil',
            'data' => [
                'token' => $token,
                'user' => [
                    'id'    => $user->id,
                    'name'  => $user->name,
                    'phone' => $user->phone,
                    'role'  => $user->role,
                ]
            ]
        ]);
    }

    public function register(Request $request)
    {
        $request->validate([
            'name'     => 'required|string|max:255',
            'phone'    => ['required', 'string', 'unique:users,phone'],
            'password' => 'required|min:6|confirmed',
        ]);

        $normalizedPhone = $this->normalizePhone($request->phone);

        $user = User::create([
            'name'     => $request->name,
            'phone'    => $normalizedPhone,
            'role'     => 'customer',
            'password' => Hash::make($request->password),
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Registrasi berhasil',
            'data' => [
                'token' => $token,
                'user' => [
                    'id'    => $user->id,
                    'name'  => $user->name,
                    'phone' => $user->phone,
                    'role'  => $user->role,
                ]
            ]
        ], 201);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Berhasil logout'
        ]);
    }

    public function me(Request $request)
    {
        return response()->json([
            'success' => true,
            'data' => $request->user()
        ]);
    }
}
