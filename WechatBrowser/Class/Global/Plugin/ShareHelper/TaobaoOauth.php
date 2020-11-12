<?php
class oauth extends core {
	private $taobao_app_key, $taobao_app_secrect;
	private $weibo_app_key, $weibo_app_secrect;
	private $qq_app_key, $qq_app_secrect;

	public function __construct() {
		parent::__construct();
		$this->taobao_app_key = '23065843';
		$this->taobao_app_secrect = 'ebd6aa667f48228749ebbdd5b9c3349f';
	}

	public function taobao() {
		include_once FRAMEWORK_PATH."/third/oauth/taobao/TopSdk.php";
		$redirect_uri = urlencode("http://www.syoker.com/api.php?app=oauth&act=taobao_callback");
		$url = "https://oauth.taobao.com/authorize?response_type=code&client_id={$this->taobao_app_key}&redirect_uri={$redirect_uri}&view=wap";
		header("Location: {$url}");
	}

	public function taobao_callback() {
		$code = (isset($_GET['code']) && trim($_GET['code'])) ? trim($_GET['code']) : '';
		if ($code) {
			$redirect_uri = urlencode("http://www.syoker.com/api.php?app=oauth&act=taobao_complete");
			$url = 'https://oauth.taobao.com/token';
			$postfields = array('grant_type' => 'authorization_code',
				'client_id' => $this->taobao_app_key,
				'client_secret' => $this->taobao_app_secrect,
				'code' => $code,
				'redirect_uri' => $redirect_uri);
			$post_data = '';
			foreach ($postfields as $key=>$value) {
			    $post_data .= "$key=" . urlencode($value) . "&";
			}
			$ch = curl_init();
			curl_setopt($ch, CURLOPT_URL, $url);
			curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
			curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 0);  
			curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 0);
			//指定post数据
			curl_setopt($ch, CURLOPT_POST, true);
			//添加变量
			curl_setopt($ch, CURLOPT_POSTFIELDS, substr($post_data, 0, -1));
			$output = curl_exec($ch);
			$httpStatusCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
			curl_close($ch);
			if ($httpStatusCode == '200') {
				//echo $obj->taobao_user_id;
				//$_SESSION['taobaoOauth'] = $obj;
				//$str = serialize($obj);
				$obj = json_decode($output);
				$str = "&taobao_user_id={$obj->taobao_user_id}&taobao_user_nick={$obj->taobao_user_nick}";
				header("Location:/api.php?app=oauth&act=taobao_complete{$str}");
			} else {
				error($httpStatusCode . ':无法获得授权');
			}
		} else {
			error('无法获得授权');
		}
	}

	public function taobao_access() {
		//dummy
	}

	public function taobao_complete() {
		//$obj = isset($_SESSION['taobaoOauth']) ? $_SESSION['taobaoOauth'] : '';
		$id = (isset($_GET['taobao_user_id']) && trim($_GET['taobao_user_id'])) ? trim($_GET['taobao_user_id']) : '';
		$name = (isset($_GET['taobao_user_nick']) && trim($_GET['taobao_user_nick'])) ? trim($_GET['taobao_user_nick']) : '';
		//var_dump($_GET);
		if ($id=='') {
			error('没有相关信息');
		}
		success(array("id"=>$id, "name"=>$name));
		//$_SESSION['taobaoOauth'] = '';
		//unset($_SESSION['taobaoOauth']);
	}	
}
?>