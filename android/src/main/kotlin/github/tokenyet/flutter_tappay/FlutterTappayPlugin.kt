package github.tokenyet.flutter_tappay

import android.app.Activity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.BinaryMessenger
import android.content.Context
import android.content.BroadcastReceiver
import android.content.Intent
import android.util.Log
import android.content.IntentFilter
import android.media.session.MediaSession
import android.os.Handler
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding



/** FlutterTappayPlugin */
public class FlutterTappayPlugin : FlutterPlugin, StreamHandler, MethodCallHandler, ActivityResultListener, ActivityAware {
    private var applicationContext: Context? = null
    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var activityPluginBinding: ActivityPluginBinding? = null
    var token: String? = null
        set(value) {
            field = value
            success = true
            Log.d("Callback", "$field,$success,${eventSink == null}")
            eventSink?.success(token)
        }
    var success: Boolean = false
    var activity: Activity? = null

    companion object {
        val instance = FlutterTappayPlugin()
        // 幹你媽的 flutter v2 開始不用這個 那 cli 產生這個衝三小
        /*@JvmStatic
        fun registerWith(registrar: Registrar) {
            Log.d("FFFFFFFFFFFFFFFFFF", "registerWith")
            registrar.addActivityResultListener(instance);
            instance.onAttachedToEngine(registrar.context(), registrar.messenger());
            instance.activity = registrar.activity()
            if(instance.activity == null)
                Log.d("FFFFFFFFFFFFFFFFFF", "REGISTER WITH NULL ACTIVITY")
        }*/
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d("FFFFFFFFFFFFFFFFFF", "onAttachedToEngine")
        onAttachedToEngine(binding.applicationContext, binding.binaryMessenger)
    }

    private fun onAttachedToEngine(applicationContext: Context, messenger: BinaryMessenger) {
        Log.d("FFFFFFFFFFFFFFFFFF", "_onAttachedToEngine")
        this.applicationContext = applicationContext
        methodChannel = MethodChannel(messenger, "tokenyet.github.io/flutter_tappay")
        methodChannel?.setMethodCallHandler(this)
        eventChannel = EventChannel(messenger, "tokenyet.github.io/flutter_tappay_callback")
        eventChannel?.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d("FFFFFFFFFFFFFFFFFF", "onDetachedFromEngine")
        applicationContext = null
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        eventChannel = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else if (call.method == "showPayment") {
            var intent = Intent(applicationContext, TappayActivity::class.java)
            var title = call.argument<String>("title")
            var btnName = call.argument<String>("btnName")
            intent.putExtra("TITLE", if (title != null) title else "Tappay Example Title")
            intent.putExtra("BTN_NAME", if (btnName != null) btnName else "Pay")
            activityPluginBinding!!.activity!!.startActivityForResult(intent, 8787)
            result.success("Yo")
        } else if (call.method == "getToken") {
            if (this.token != null)
                result.success(token)
            else
                result.error("No token hooked", null, null)
        } else {
            result.notImplemented()
        }
    }

//    fun onDetect(events: EventSink?) {
//      Log.d("ONDETECT", "$success, $token")
//      if(success) {
//        this.success = false
//        events?.success(this.token)
//      }
//      Handler().postDelayed({ onDetect(events) }, 1000)
//    }

    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventSink?) {
      //onDetect(events)
      eventSink = events;
      Log.d("HOOK EVENT SINK", "${arguments == null}, ${events == null}")
    }

    override fun onCancel(arguments: Any?) {

    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        Log.d("$requestCode $resultCode", ".....")
        if(requestCode == 8787) {
            Log.d("Callback Result", "yo")
            eventSink?.success(data?.getStringExtra("token"))
            Log.d("Callback Result", "yo! ${data?.getStringExtra("token")}")
            return true
        }
        return false
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityPluginBinding = binding
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityPluginBinding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityPluginBinding = binding
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activityPluginBinding = null
    }
}
