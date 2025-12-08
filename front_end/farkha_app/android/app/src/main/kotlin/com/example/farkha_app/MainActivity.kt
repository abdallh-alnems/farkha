package ni.nims.frkha

import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Enable edge-to-edge display for Android 15+ (API 35) compatibility
        // This ensures content extends behind system bars
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }
}
