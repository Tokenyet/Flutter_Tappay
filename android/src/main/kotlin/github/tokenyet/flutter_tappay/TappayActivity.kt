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
    private var context: Context? = null
    private val TAG = "TappayActivity"
    private var pendingName: String? = null
    private var btnName: String? = null

    companion object {
        val INTENT_TITLE = "TITLE";
        val INTENT_BTN_NAME = "BTN_NAME";
        val INTENT_PENDING_BTN_NAME = "PENDING_BTN_NAME";
        val INTENT_APP_KEY = "APP_KEY";
        val INTENT_APP_ID = "APP_ID";
        val INTENT_SERVER_TYPE = "SERVER_TYPE";
    }


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        var title = getIntent().getStringExtra(INTENT_TITLE)
        var btnName = getIntent().getStringExtra(INTENT_BTN_NAME)
        var pendingBtnName = getIntent().getStringExtra(INTENT_PENDING_BTN_NAME)
        setupViews(title, btnName)
        this.pendingName = pendingBtnName
        this.btnName = btnName
        context = this

        var appKey = getIntent().getStringExtra(INTENT_APP_KEY)
        var appId = getIntent().getIntExtra(INTENT_APP_ID, 11334)
        var serverType = getIntent().getStringExtra(INTENT_SERVER_TYPE)
        startTapPaySetting(appId, appKey, serverType);
    }


    private fun setupViews(title: String, btnName: String) {
        //statusTV = findViewById(R.id.statusTV) as TextView
        tipsTV = findViewById(R.id.tipsTV) as TextView
        payBTN = findViewById(R.id.payBTN) as Button
        payBTN!!.setOnClickListener(this)
        payBTN!!.isEnabled = false
        payBTN!!.text = btnName
        setTitle(title)
        //setPayBtn(true)
    }

    private fun startTapPaySetting(appId: Int = 11334, appKey: String = "app_whdEWBH8e8Lzy4N6BysVRRMILYORF6UxXbiOFsICkz0J9j1C0JUlCHv1tVJC", serverType: String = "sandbox") {
        //1.Setup environment.
        if(serverType.toLowerCase() == "production") { // TPDServerType classifier, wtf is this...
            TPDSetup.initInstance(getApplicationContext(), appId, appKey, TPDServerType.Production)
        } else {
            TPDSetup.initInstance(getApplicationContext(), appId, appKey, TPDServerType.Sandbox)
        }


        //2.Setup input form
        tpdForm = findViewById(R.id.tpdCardInputForm) as TPDForm
        tpdForm!!.setTextErrorColor(Color.RED)
        tpdForm!!.setOnFormUpdateListener(object : TPDFormUpdateListener {
            override fun onFormUpdated(tpdStatus: TPDStatus) {
                //Toast.makeText(context, "status: ${tpdStatus.toString()}", Toast.LENGTH_SHORT).show()
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
                //Toast.makeText(context, "$token", Toast.LENGTH_LONG).show()
                // Log.d("TPDirect createToken", "cardIdentifier:  $cardIdentifier")
                //payBTN!!.isEnabled = true
                setPayBtn(false)
                var resultIntent = Intent();
                resultIntent.putExtra("token", token);
                setResult(Activity.RESULT_OK, resultIntent);
                finish()
            }
        }
        val tpdTokenFailureCallback = object : TPDTokenFailureCallback {
            override fun onFailure(status: Int, reportMsg: String) {
                //Toast.makeText(context, "$status $reportMsg", Toast.LENGTH_LONG).show()
                //Log.d("TPDirect createToken", "failure: $status$reportMsg")
                //payBTN!!.isEnabled = true
                setPayBtn(false)
                Log.d("TPDirect createToken", "failure: $status$reportMsg")
                var resultIntent = Intent();
                resultIntent.putExtra("error", "$status|$reportMsg");
                setResult(Activity.RESULT_OK, resultIntent);
                finish()
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
            R.id.payBTN -> run {
                //payBTN!!.isEnabled = false // prevent user from thinking the btn not works
                setPayBtn(true)
                //4. Calling API for obtaining prime.
                if (tpdCard != null) {
                    // Toast.makeText(context, "click", Toast.LENGTH_LONG).show()
                    tpdCard!!.getPrime()
                }
            }
        }
    }

    fun setPayBtn(pending: Boolean) {
        if(pending) {
            payBTN!!.text = pendingName
            payBTN!!.isEnabled = false
        }
        else {
            payBTN!!.text = btnName
            payBTN!!.isEnabled = true
        }
    }
}