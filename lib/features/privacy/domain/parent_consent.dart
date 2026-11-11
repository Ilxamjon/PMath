import '../../../models/user_model.dart';

/// Kamera, yuz tekshiruvi va daftar rasmini yuborish.
bool parentAllowsCamera(UserModel? user) =>
    user?.parentConsentGranted == true;
