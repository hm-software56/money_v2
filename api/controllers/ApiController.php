<?php

namespace app\controllers;
use yii;
use app\models\User;
use yii\web\Response;
use app\models\Payment;
use app\models\TypePay;
use app\models\RecieveMoney;
use app\models\TyeReceive;
use app\models\DaoCar;

use Imagine\Image\Box;
use yii\imagine\Image;
use yii\web\UploadedFile;

class ApiController extends \yii\web\Controller
{
    
    public function actionIndex()
    {
        return $this->render('index');
    }

    public function actionLogin(){
        
        $model=User::find()->where(['username'=>$_POST['username'],'password'=>$_POST['password']])->asArray()->one();
        if(!empty($model))
        {
			$user=User::find()->where(['id'=>$model['id']])->one();
            $user->player_id=$_POST['player_id'];
            $user->save();

            \Yii::$app->response->format=Response::FORMAT_JSON;
            return $model;
        }else{
            $model=['error'=>'ຊື່​ເຂົ້າ​ລະ​ບ​ົບ ຫຼຶ​ ລະ​ຫັດ​ຜ່ານ​ບໍ​ຖືກ​ຕ້ອງ'];
            \Yii::$app->response->format=Response::FORMAT_JSON;
            return $model;
        }
    }

    public function actionHome(){
        $sum_pay =\Yii::$app->db->createCommand('SELECT sum(amount) FROM payment where year(date)='.date('Y').'')->queryScalar();
        $sum_recive =\Yii::$app->db->createCommand('SELECT sum(amount) FROM recieve_money where year(date)='.date('Y').'')->queryScalar();
        $percent_pay=($sum_pay*100)/$sum_recive;
        $percent_recive=100-$percent_pay;
        $result=['total_pay'=>\number_format($sum_pay,2),'total_recieve'=>\number_format($sum_recive,2),'percent_pay'=>sprintf('%0.2f',$percent_pay),'percent_recive'=>sprintf('%0.2f',$percent_recive)];
       
        $pay_car =\Yii::$app->db->createCommand('SELECT sum(amount) FROM dao_car where status IN("Paid","Saving")')->queryScalar();
        $still_pay=17470-($pay_car+5539);
        $result_car=['pay_car'=>number_format($pay_car+5539,2),'still_car'=>number_format($still_pay,2)];
        
        $result=array_merge($result,$result_car);

        \Yii::$app->response->format=Response::FORMAT_JSON;
        return $result;
    }
	
	public function actionCharty(){
		$result=[];
		for($i=0;$i<=4;$i++)
		{
			$y = date('Y', strtotime('-'.$i.' years'));
			$sum_pay =\Yii::$app->db->createCommand('SELECT sum(amount) FROM payment where year(date)='.$y.'')->queryScalar();
			$sum_recive =\Yii::$app->db->createCommand('SELECT sum(amount) FROM recieve_money where year(date)='.$y.'')->queryScalar();
			$result[]=['pay'=>(int)$sum_pay,'recive'=>(int)$sum_recive,'year'=>$y];
	   }


        \Yii::$app->response->format=Response::FORMAT_JSON;
        return $result;
    }
	public function actionChartm(){
		$result=[];
		for($i=0;$i<=5;$i++)
		{
			$m=date("m", strtotime("-".$i." month"));
			$sum_pay =\Yii::$app->db->createCommand('SELECT sum(amount) FROM payment where month(date)='.$m.'')->queryScalar();
			$sum_recive =\Yii::$app->db->createCommand('SELECT sum(amount) FROM recieve_money where month(date)='.$m.'')->queryScalar();
			$result[]=['pay'=>(int)$sum_pay,'recive'=>(int)$sum_recive,'year'=>$m];
	   }
       \Yii::$app->response->format=Response::FORMAT_JSON;
       return $result;
    }

    public function actionUplaodfile()
    {
        $uploads = UploadedFile::getInstancesByName("upfile");
        if (empty($uploads)) {
            return "Must upload at least 1 file in upfile form-data POST";
        }

        // $uploads now contains 1 or more UploadedFile instances
        $savedfiles = null;
        foreach ($uploads as $file) {
            $realFileName = rand(). time() . '.' . $file->extension;
            $path = \Yii::$app->basePath . '/web/images/' . $realFileName; //Generate your save file path here;
            if ($file->saveAs($path)) {
                $savedfiles = $realFileName;
                $imagine = Image::getImagine();
                $image = $imagine->open(\Yii::$app->basePath . '/web/images/' . $savedfiles);
                if(isset($_POST['name']) && ($_POST['name']=="profile_img" || $_POST['name']=="profileBg_img"))
                {
                    $image->save(\Yii::$app->basePath . '/web/images/small/' . $savedfiles, ['quality' => 60]);
                }
                
            } else {
                $savedfiles = 'Error save file';
            } //Your uploaded file is saved, you can process it further from here
        }

        /*======== Use for update profile profile bg ========*/
        if(isset($_POST['edit']))
        {
            if(isset($_POST['name']) && $_POST['name']=='profile_img')
            {
                User::updateAll(['photo' =>$savedfiles], 'id='.$_POST['userid'].'');
            }elseif(isset($_POST['name']) && $_POST['name']=='profileBg_img')
            {
                User::updateAll(['bg_photo' =>$savedfiles], 'id='.$_POST['userid'].'');
            }
        }
        \Yii::$app->response->format = Response::FORMAT_JSON;
        return $savedfiles;

    }
     public function actionListpayment1(){
        $model=Payment::find()
        ->asArray()->orderby('date DESC,id DESC')->all();
        \Yii::$app->response->format = Response::FORMAT_JSON;
        return $model;
    }

    public function actionListpayment(){
        $model=Payment::find()
        ->joinWith(['typePay','user'])
        ->asArray()->orderby('date DESC,id DESC')->limit(50)->all();
        \Yii::$app->response->format = Response::FORMAT_JSON;
        return $model;
    }
	
	/* ============= Report payment by week =====*/
	public function actionListpaymentweekpage($pageoffset,$pagesize){
		$w_first= date("Y-m-d", strtotime('monday this week '));  
        $w_last=date("Y-m-d", strtotime('sunday this week '));
        $model=Payment::find()
        ->joinWith(['typePay','user'])
		->where('payment.date>="'.$w_first.'" and payment.date<="'.$w_last.'"')
        ->asArray()->orderby('payment.date DESC,id DESC')->limit($pagesize)->offset($pageoffset)->all();
        \Yii::$app->response->format = Response::FORMAT_JSON;
        return $model;
    }
	public function actionCountpayweekrecode(){
		$w_first= date("Y-m-d", strtotime('monday this week '));  
        $w_last=date("Y-m-d", strtotime('sunday this week '));
        $modelcount=Payment::find()->where('date>="'.$w_first.'" and date<="'.$w_last.'"')->count();
        $modelsum=Payment::find()->where('date>="'.$w_first.'" and date<="'.$w_last.'"')->sum('amount');
        if(empty($modelsum)){
            $modelsum=0;
        }
        if(empty($modelsum)){
            $modelcount=0;
        }
        \Yii::$app->response->format = Response::FORMAT_JSON;
        return ['count'=>$modelcount,'sum'=>$modelsum];
    }
	/*============== End ===============*/
	
	/* ============= Report payment by month =====*/
	public function actionListpaymentmonthpage($pageoffset,$pagesize){
		$m_first=date('Y-m-d', strtotime("first day of this month"));
        $m_last=date('Y-m-d', strtotime("last day of this month"));
        $model=Payment::find()
        ->joinWith(['typePay','user'])
		->where('payment.date>="'.$m_first.'" and payment.date<="'.$m_last.'"')
        ->asArray()->orderby('payment.date DESC,id DESC')->limit($pagesize)->offset($pageoffset)->all();
        \Yii::$app->response->format = Response::FORMAT_JSON;
        return $model;
    }
	public function actionCountpaymonthrecode(){
		$m_first=date('Y-m-d', strtotime("first day of this month"));
        $m_last=date('Y-m-d', strtotime("last day of this month"));
        $modelcount=Payment::find()->where('date>="'.$m_first.'" and date<="'.$m_last.'"')->count();
		$modelsum=Payment::find()->where('date>="'.$m_first.'" and date<="'.$m_last.'"')->sum('amount');
        \Yii::$app->response->format = Response::FORMAT_JSON;
        if(empty($modelsum)){
            $modelsum=0;
        }
        if(empty($modelsum)){
            $modelcount=0;
        }
        return ['count'=>$modelcount,'sum'=>$modelsum];
    }
	/*============== End ===============*/
	
	/* ============= Report payment by year =====*/
	public function actionListpaymentyearpage($pageoffset,$pagesize){
		$y_first=date("Y-m-d",strtotime("this year January 1st"));
        $y_last=date("Y-m-d",strtotime("this year December 31st"));
        $model=Payment::find()
        ->joinWith(['typePay','user'])
		->where('payment.date>="'.$y_first.'" and payment.date<="'.$y_last.'"')
        ->asArray()->orderby('payment.date DESC,id DESC')->limit($pagesize)->offset($pageoffset)->all();
        \Yii::$app->response->format = Response::FORMAT_JSON;
        return $model;
    }
	public function actionCountpayyearrecode(){
		$y_first=date("Y-m-d",strtotime("this year January 1st"));
        $y_last=date("Y-m-d",strtotime("this year December 31st"));
        $modelcount=Payment::find()->where('date>="'.$y_first.'" and date<="'.$y_last.'"')->count();
        $modelsum=Payment::find()->where('date>="'.$y_first.'" and date<="'.$y_last.'"')->sum('amount');
        if(empty($modelsum)){
            $modelsum=0;
        }
        if(empty($modelsum)){
            $modelcount=0;
        }
        \Yii::$app->response->format = Response::FORMAT_JSON;
        return ['count'=>$modelcount,'sum'=>$modelsum];
    }
	/*============== End ===============*/
	
	
	/* ============= Report recive by week =====*/
	public function actionListreciveweekpage($pageoffset,$pagesize){
		$w_first= date("Y-m-d", strtotime('monday this week '));  
        $w_last=date("Y-m-d", strtotime('sunday this week '));
        $model=RecieveMoney::find()
        ->joinWith(['tyeReceive','user'])
		->where('recieve_money.date>="'.$w_first.'" and recieve_money.date<="'.$w_last.'"')
        ->asArray()->orderby('recieve_money.date DESC,id DESC')->limit($pagesize)->offset($pageoffset)->all();
        \Yii::$app->response->format = Response::FORMAT_JSON;
        return $model;
    }
	public function actionCountreciveweekrecode(){
		$w_first= date("Y-m-d", strtotime('monday this week '));  
        $w_last=date("Y-m-d", strtotime('sunday this week '));
        $modelcount=RecieveMoney::find()->where('date>="'.$w_first.'" and date<="'.$w_last.'"')->count();
        $modelsum=RecieveMoney::find()->where('date>="'.$w_first.'" and date<="'.$w_last.'"')->sum('amount');
        if(empty($modelsum)){
            $modelsum=0;
        }
        if(empty($modelsum)){
            $modelcount=0;
        }
        \Yii::$app->response->format = Response::FORMAT_JSON;
        return ['count'=>$modelcount,'sum'=>$modelsum];
    }
	/*============== End ===============*/
	
	/* ============= Report recive by month =====*/
	public function actionListrecivemonthpage($pageoffset,$pagesize){
		$m_first=date('Y-m-d', strtotime("first day of this month"));
        $m_last=date('Y-m-d', strtotime("last day of this month"));
        $model=RecieveMoney::find()
        ->joinWith(['tyeReceive','user'])
		->where('recieve_money.date>="'.$m_first.'" and recieve_money.date<="'.$m_last.'"')
        ->asArray()->orderby('recieve_money.date DESC,id DESC')->limit($pagesize)->offset($pageoffset)->all();
        \Yii::$app->response->format = Response::FORMAT_JSON;
        return $model;
    }
	public function actionCountrecivemonthrecode(){
		$m_first=date('Y-m-d', strtotime("first day of this month"));
        $m_last=date('Y-m-d', strtotime("last day of this month"));
        $modelcount=RecieveMoney::find()->where('date>="'.$m_first.'" and date<="'.$m_last.'"')->count();
        $modelsum=RecieveMoney::find()->where('date>="'.$m_first.'" and date<="'.$m_last.'"')->sum('amount');
        if(empty($modelsum)){
            $modelsum=0;
        }
        if(empty($modelsum)){
            $modelcount=0;
        }
        \Yii::$app->response->format = Response::FORMAT_JSON;
        return ['count'=>$modelcount,'sum'=>$modelsum];
    }
	/*============== End ===============*/
	
	/* ============= Report payment by year =====*/
	public function actionListreciveyearpage($pageoffset,$pagesize){
		$y_first=date("Y-m-d",strtotime("this year January 1st"));
        $y_last=date("Y-m-d",strtotime("this year December 31st"));
        $model=RecieveMoney::find()
        ->joinWith(['tyeReceive','user'])
		->where('recieve_money.date>="'.$y_first.'" and recieve_money.date<="'.$y_last.'"')
        ->asArray()->orderby('recieve_money.date DESC,id DESC')->limit($pagesize)->offset($pageoffset)->all();
        \Yii::$app->response->format = Response::FORMAT_JSON;
        return $model;
    }
	public function actionCountreciveyearrecode(){
		$y_first=date("Y-m-d",strtotime("this year January 1st"));
        $y_last=date("Y-m-d",strtotime("this year December 31st"));
        $modelcount=RecieveMoney::find()->where('date>="'.$y_first.'" and date<="'.$y_last.'"')->count();
        $modelsum=RecieveMoney::find()->where('date>="'.$y_first.'" and date<="'.$y_last.'"')->sum('amount');
        if(empty($modelsum)){
            $modelsum=0;
        }
        if(empty($modelsum)){
            $modelcount=0;
        }
        \Yii::$app->response->format = Response::FORMAT_JSON;
        return ['count'=>$modelcount,'sum'=>$modelsum];
    }
	/*============== End ===============*/
	
    public function actionListrecive(){
        $model=RecieveMoney::find()
        ->joinWith(['tyeReceive','user'])
        ->asArray()->orderby('date DESC,id DESC')->limit(50)->all();
        \Yii::$app->response->format = Response::FORMAT_JSON;
        return $model;
    }
    
    public function actionListrecive1(){
        $model=RecieveMoney::find()
        ->asArray()->orderby('date DESC,id DESC')->all();
        \Yii::$app->response->format = Response::FORMAT_JSON;
        return $model;
    }
	
	public function actionListdaocar(){
        $model=DaoCar::find()
        ->asArray()->orderby('date DESC')->all();
		\Yii::$app->response->format = Response::FORMAT_JSON;
        return $model;
    }

	public function actionSumdaocar()
	{
		$saving=\Yii::$app->db->createCommand('SELECT sum(amount) FROM dao_car where status="Saving"')->queryScalar();
        $paid=\Yii::$app->db->createCommand('SELECT sum(amount) FROM dao_car where status="Paid"')->queryScalar();
        $remark=\Yii::$app->db->createCommand('SELECT sum(amount) FROM dao_car where status="remark"')->queryScalar();
       $paid="".($paid+5539)."";
        $model=['saving'=>$saving,'paid'=>$paid,'remark'=>$remark];
	   \Yii::$app->response->format = Response::FORMAT_JSON;
        return $model; 
	}
    public function actionListtypepay(){
        $model=TypePay::find()->all();
        \Yii::$app->response->format = Response::FORMAT_JSON;
        return $model;
    }
	public function actionListtyperecive(){
        $model=TyeReceive::find()->all();
        \Yii::$app->response->format = Response::FORMAT_JSON;
        return $model;
    }

    public function actionCreateorupdatepayment(){
        if(isset($_POST['amount']))
        {
            if($_POST['id']=='null')
            {
                $model=new Payment();
                $model->refer_id=substr(md5(mt_rand()),0,7).date('Ymdhis');
            }else{
                $model=Payment::find()->where(['id'=>(int)$_POST['id']])->one();
            }
            $model->amount=str_ireplace("," ,"",substr($_POST['amount'],0,-3));
            $model->description=$_POST['description'];
            $model->date=date('Y-m-d',strtotime($_POST['date']));
            $model->type_pay_id=$_POST['type_id'];
            $model->user_id=$_POST['user_id'];
            if($model->save())
            {
                $result=true;
                if($_POST['id']=='null')
                {
                    $subject = "ປ້ອນ​ລາຍ​ຈ່າຍ (" . $model->user->first_name . ")";
                    $sms = 'ຈ່າຍໂດຍ:' . $model->user->first_name . ", ປະ​ເພດ​ລາຍ​ຈ່າຍ:" . $model->typePay->name . ', ຈຳ​ນວນ​ເງີນ​ຈ່າຍ:' . number_format($model->amount) . 'ກີບ, ວັ​ນ​ທີຈ່າຍ:' . $model->date;
                
                }else{
                    $subject = "ແກ້​ໄຂ​ລາຍ​ຈ່າຍ (" . $model->user->first_name . ")";
                    $sms = 'ແກ້​ໄຂ​ລາຍ​ຈ່າຍໂດຍ:' . $model->user->first_name . ", ປະ​ເພດ​ລາຍ​ຈ່າຍ:" . $model->typePay->name . ', ຈຳ​ນວນ​ເງີນ​ຈ່າຍ:' . number_format($model->amount) . 'ກີບ, ວັ​ນ​ທີຈ່າຍ:' . $model->date;
                
                }
                $tilte = "ຈ່າຍໂດຍ: (" . $model->user->first_name . ")<br/>";
                $body = "ປະ​ເພດ​ລາຍ​ຈ່າຍ: " . $model->typePay->name . "<br/>";
                if (!empty($model->description)) {
                    $body.=$model->description . '<br/>';
                }
                $body.="ຈຳ​ນວນ​ເງີນ​ຈ່າຍ: " . number_format($model->amount) . "ກີບ<br/>";
                $body.="ວັ​ນ​ທີຈ່າຍ: " . $model->date;

                $payment_notification = Payment::onesignalnotification($sms,$model->user_id);

                $sms = new \app\models\Sms();
                $sms->details = $body;
                $sms->title = $tilte;
                $sms->by_user = $model->user_id;
                $sms->save();

            }else{
                $result='ທ່ານ​ຕ້ອງ​ປ້ອນ​ຂໍ້​ມ​ູນ​ໃຫ້​​ຄອບ​ກ່ອນ.!';
            }
            \Yii::$app->response->format = Response::FORMAT_JSON;
            return $result;
        }
    }
	
	public function actionCreateorupdaterecive(){
        if(isset($_POST['amount']))
        {
            if($_POST['id']=='null')
            {
                $model=new RecieveMoney();
                $model->refer_id=substr(md5(mt_rand()),0,7).date('Ymdhis');
            }else{
                $model=RecieveMoney::find()->where(['id'=>(int)$_POST['id']])->one();
            }
            $model->amount=str_ireplace("," ,"",substr($_POST['amount'],0,-3));
            $model->description=$_POST['description'];
            $model->date=date('Y-m-d',strtotime($_POST['date']));
            $model->tye_receive_id=$_POST['type_id'];
            $model->user_id=$_POST['user_id'];
            if($model->save())
            {
                $result=true;
                if($_POST['id']=='null')
                {
                    $subject = "ປ້ອນ​ລາຍ​ຮັບ (" . $model->user->first_name . ")";
                    $sms = 'ຮັບໂດຍ:' . $model->user->first_name . ", ປະ​ເພດ​ລາຍ​ຮັບ:" . $model->tyeReceive->name . ', ຈຳ​ນວນ​ເງີນ​ຮັບ:' . number_format($model->amount) . 'ກີບ, ວັ​ນ​ທີຮັບ:' . $model->date;
                
                }else{
                    $subject = "ແກ້​ໄຂ​ຮັບ (" . $model->user->first_name . ")";
                    $sms = 'ແກ້​ໄຂ​ລາຍ​ຮັບໂດຍ:' . $model->user->first_name . ", ປະ​ເພດ​ລາຍ​ຮັບ:" . $model->tyeReceive->name . ', ຈຳ​ນວນ​ເງີນ​ຮັບ:' . number_format($model->amount) . 'ກີບ, ວັ​ນ​ທີຮັບ:' . $model->date;
                
                }
                $tilte = "ຮັບໂດຍ: (" . $model->user->first_name . ")<br/>";
                $body = "ປະ​ເພດ​ລາຍ​ຮັບ: " . $model->tyeReceive->name . "<br/>";
                if (!empty($model->description)) {
                    $body.=$model->description . '<br/>';
                }
                $body.="ຈຳ​ນວນ​ເງີນ​ຮັບ: " . number_format($model->amount) . "ກີບ<br/>";
                $body.="ວັ​ນ​ທີຮັບ: " . $model->date;

                $payment_notification = Payment::onesignalnotification($sms,$model->user_id);

                $sms = new \app\models\Sms();
                $sms->details = $body;
                $sms->title = $tilte;
                $sms->by_user = $model->user_id;
                $sms->save();
            }else{
                $result='ທ່ານ​ຕ້ອງ​ປ້ອນ​ຂໍ້​ມູ​ນ​ໃຫ້​​ຄອບ​ກ່ອນ.!';
            }
            \Yii::$app->response->format = Response::FORMAT_JSON;
            return $result;
        }
    }

	public function actionCreateorupdatedaocar(){
        if(isset($_POST['amount']))
        {
            if($_POST['id']=='null')
            {
                $model=new DaoCar();
                $model->refer_id=substr(md5(mt_rand()),0,7).date('Ymdhis');
            }else{
                $model=DaoCar::find()->where(['id'=>(int)$_POST['id']])->one();
            }
            $model->amount=$_POST['amount'];
            $model->status=$_POST['status'];
            $model->date=date('Y-m-d',strtotime($_POST['date']));
            $model->remark=$_POST['remark'];
            if($model->save())
            {
                $result=true;
            }else{
                $result='ທ່ານ​ຕ້ອງ​ປ້ອນ​ຂໍ້​ມູ​ນ​ໃຫ້​​ຄອບ​ກ່ອນ.!';
            }
            \Yii::$app->response->format = Response::FORMAT_JSON;
            return $result;
        }
    }

	
    public function actionPaymentdelete($id)
    {
        $model=Payment::find()->where(['id'=>$id])->one();
        if($model->delete())
        {
            return $this->redirect(['api/listpayment']);
        }
    }
	public function actionRecivedelete($id)
    {
        $model=RecieveMoney::find()->where(['id'=>$id])->one();
        if($model->delete())
        {
            return $this->redirect(['api/listrecive']);
        }
    }

    public function actionListpaymentpk($id){
        $model=Payment::find()
        ->joinWith(['typePay','user'])
        ->asArray()->where(['payment.id'=>$id])->orderby('id DESC ,date DESC')->one();
        \Yii::$app->response->format = Response::FORMAT_JSON;
        return $model;
    }
	
	public function actionListrecivepk($id){
        $model=RecieveMoney::find()
        ->joinWith(['tyeReceive','user'])
        ->asArray()->where(['recieve_money.id'=>$id])->orderby('id DESC ,date DESC')->one();
        \Yii::$app->response->format = Response::FORMAT_JSON;
        return $model;
    }
	public function actionListdaocarpk($id){
        $model=DaoCar::find()
        ->asArray()->where(['id'=>$id])->orderby('id DESC ,date DESC')->one();
        \Yii::$app->response->format = Response::FORMAT_JSON;
        return $model;
    }


/*=============== search payment ==============*/
public function actionListpaymentsearch(){
    $first= date('Y-m-d',strtotime($_POST['date_start']));  
    $last=date('Y-m-d',strtotime($_POST['date_end']));
    ;
    if(!empty($_POST['type_id']))
    {
    $model=Payment::find()
        ->joinWith(['typePay','user'])
        ->where('payment.date>="'.$first.'" and payment.date<="'.$last.'"')
        ->andWhere(['type_pay_id'=>$_POST['type_id']])
        ->asArray()->orderby('payment.date DESC,id DESC')->all();
    }else{
        $model=Payment::find()
        ->joinWith(['typePay','user'])
        ->where('payment.date>="'.$first.'" and payment.date<="'.$last.'"')
        ->asArray()->orderby('payment.date DESC,id DESC')->all();
    }
    \Yii::$app->response->format = Response::FORMAT_JSON;
    return $model;
}
public function actionCountpaymentsearch(){
    $first= date('Y-m-d',strtotime($_POST['date_start']));  
    $last=date('Y-m-d',strtotime($_POST['date_end']));
    if (!empty($_POST['type_id'])) {
        $modelsum=Payment::find()->where('date>="'.$first.'" and date<="'.$last.'"')
        ->andWhere(['type_pay_id'=>$_POST['type_id']])->sum('amount');
    } else{
        $modelsum=Payment::find()->where('date>="'.$first.'" and date<="'.$last.'"')->sum('amount');
    }
    \Yii::$app->response->format = Response::FORMAT_JSON;
    return ['sum'=>$modelsum];
}
/*============== End ===============*/
    public function actionTest()
    {
		echo substr('8,000.00',0,-3);
        //$payment_notification = Payment::onesignalnotification('sss',4);
    }
}
