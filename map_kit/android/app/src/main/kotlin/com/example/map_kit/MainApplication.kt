package com.example.map_kit

import android.app.Application

import com.yandex.mapkit.MapKitFactory

class MainApplication: Application() {
    override fun onCreate() {
        super.onCreate()
        MapKitFactory.setApiKey("83cb202e-ece6-46d2-8faa-76e060df8e2c")
    }
}