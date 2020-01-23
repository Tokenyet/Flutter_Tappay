package github.tokenyet.flutter_tappay


import github.tokenyet.flutter_tappay.R
import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.os.PersistableBundle
import android.util.Log
import android.view.View
import android.widget.Button
import android.widget.TextView
import android.widget.Toast
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.activity.OnBackPressedCallback
import androidx.fragment.app.Fragment
import tech.cherri.tpdirect.api.TPDCard
import tech.cherri.tpdirect.api.TPDCardInfo
import tech.cherri.tpdirect.api.TPDForm
import tech.cherri.tpdirect.api.TPDServerType
import tech.cherri.tpdirect.api.TPDSetup
import tech.cherri.tpdirect.callback.TPDCardTokenSuccessCallback
import tech.cherri.tpdirect.callback.TPDFormUpdateListener
import tech.cherri.tpdirect.callback.TPDTokenFailureCallback
import tech.cherri.tpdirect.model.TPDStatus
import androidx.appcompat.app.AppCompatActivity
import android.content.Context
import android.content.Intent



class TappayActivity : AppCompatActivity(), View.OnClickListener {
    private var tpdForm: TPDForm? = null
    private var tipsTV: TextView? = null
    private var payBTN: Button? = null
    private var tpdCard: TPDCard? = null
    //private var statusTV: TextView? = null
    //private var getFraudIdBTN: Button? = null
    private var context: Context? = null;
    private val TAG = "TappayActivity"


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        var title = getIntent().getStringExtra("TITLE")
        var btnName = getIntent().getStringExtra("BTN_NAME")
        setupViews(title, btnName)
        context = this
        Toast.makeText(this, "set view", Toast.LENGTH_SHORT).show()
        startTapPaySetting();
    }


//    protected override fun onCreate(savedInstanceState: Bundle) {
//        super.onCreate(savedInstanceState)
//        setContentView(R.layout.activity_main)
//        setupViews()
//        Log.d(TAG, "SDK version is " + TPDSetup.getVersion())
//    }

    private fun setupViews(title: String, btnName: String) {
        //statusTV = findViewById(R.id.statusTV) as TextView
        tipsTV = findViewById(R.id.tipsTV) as TextView
        payBTN = findViewById(R.id.payBTN) as Button
        payBTN!!.setOnClickListener(this)
        payBTN!!.isEnabled = false
        setTitle(title)
        payBTN!!.text = btnName
    }

    private fun startTapPaySetting() {
        Log.d(TAG, "startTapPaySetting")
        //1.Setup environment.
        TPDSetup.initInstance(getApplicationContext(),
                Integer.parseInt(getString(R.string.global_test_app_id)), getString(R.string.global_test_app_key), TPDServerType.Sandbox)

        //2.Setup input form
        tpdForm = findViewById(R.id.tpdCardInputForm) as TPDForm
        tpdForm!!.setTextErrorColor(Color.RED)
        tpdForm!!.setOnFormUpdateListener(object : TPDFormUpdateListener {
            override fun onFormUpdated(tpdStatus: TPDStatus) {
                Toast.makeText(context, "status: ${tpdStatus.toString()}", Toast.LENGTH_SHORT).show()
                tipsTV!!.text = ""
                if (tpdStatus.getCardNumberStatus() === TPDStatus.STATUS_ERROR) {
                    tipsTV!!.text = "Invalid Card Number"
                } else if (tpdStatus.getExpirationDateStatus() === TPDStatus.STATUS_ERROR) {
                    tipsTV!!.text = "Invalid Expiration Date"
                } else if (tpdStatus.getCcvStatus() === TPDStatus.STATUS_ERROR) {
                    tipsTV!!.text = "Invalid CCV"
                }
                payBTN!!.isEnabled = tpdStatus.isCanGetPrime()
            }
        })


        //3.Setup TPDCard with form and callbacks.
        val tpdTokenSuccessCallback = object : TPDCardTokenSuccessCallback {
            override fun onSuccess(token: String, tpdCardInfo: TPDCardInfo, cardIdentifier: String) {
                val cardLastFour = tpdCardInfo.getLastFour()

                Log.d("TPDirect createToken", "token:  $token")
                Log.d("TPDirect createToken", "cardLastFour:  $cardLastFour")
                Toast.makeText(context, "$token", Toast.LENGTH_LONG).show()
                FlutterTappayPlugin.instance.token = token;
                FlutterTappayPlugin.instance.success = true;
                Log.d("TPDirect createToken", "cardIdentifier:  $cardIdentifier")
                var resultIntent = Intent();
                resultIntent.putExtra("token", token);
                setResult(Activity.RESULT_OK, resultIntent);
                finish()
            }
        }
        val tpdTokenFailureCallback = object : TPDTokenFailureCallback {
            override fun onFailure(status: Int, reportMsg: String) {
                Toast.makeText(context, "$status $reportMsg", Toast.LENGTH_LONG).show()
                Log.d("TPDirect createToken", "failure: $status$reportMsg")
            }
        }

        tpdCard = TPDCard.setup(tpdForm).onSuccessCallback(tpdTokenSuccessCallback)
                .onFailureCallback(tpdTokenFailureCallback)


        //For getFraudId
        // getFraudIdBTN = findViewById(R.id.getFraudIdBTN) as Button
        // getFraudIdBTN!!.setOnClickListener(this)
    }


    override fun onClick(view: View) {
        when (view.id) {
            R.id.payBTN ->
                //4. Calling API for obtaining prime.
                if (tpdCard != null) {
                    Toast.makeText(context, "click", Toast.LENGTH_LONG).show()
                    tpdCard!!.getPrime()
                }
        }

    }
}