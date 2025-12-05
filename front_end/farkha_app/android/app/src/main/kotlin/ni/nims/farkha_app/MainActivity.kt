package ni.nims.farkha_app

import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Enable edge-to-edge display using WindowCompat
        // For Android 15+ (API 35+), edge-to-edge is automatically enabled when targeting SDK 35
        // WindowCompat.setDecorFitsSystemWindows provides compatibility across all versions
        WindowCompat.setDecorFitsSystemWindows(window, false)
        super.onCreate(savedInstanceState)
    }
}
