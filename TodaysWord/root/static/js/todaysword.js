//<!--

var url = "http://todays-word.com";
//url = "http://todays-word.com:3000";


// Other variables
var disolver;
var handle;
var ad_seconds = 10000;
var keyword_table;

// Tab sliders
var feedback_slide;

function init(){
    var images = ['/static/images/large_loader.gif'];
    var image = new Image();
    
    var ln = images.length;
    for(var x = 0; x < ln; x++) {
        image.src = images[x];
    }
}


function showFloatingBox(innerContent, innerDivID){

    //alert("in showFloatingBox with " + innerDivID);
    var boxContent = "<div id='"+innerDivID+"'><div class='FloatingBox'>" + 
                     "    <div class='FloatBoxHandle' id='FloatBoxHandle'><img src='/static/images/icons/move.png' alt='Move' /></div>" +
                     "    <div class='FloatingBoxInner'>" +
                     innerContent + 
                     "<br /><div class='button small_button' id='close_float_buttom'><a id='close' title='Close' ><img src='/static/images/icons/delete.png' alt='Close' /><span>Close</span></a></div>" +
                     "</div></div></div>";

    $('FloatBoxWrapper').innerHTML = boxContent;
    $(innerDivID).set('opacity', 0);
    $('FloatBoxWrapper').style.display = 'block';
    $(innerDivID).set('opacity', 1);

    handle = $('FloatBoxHandle');
    new Drag.Move(innerDivID, {handle: 'FloatBoxHandle'});
    myWin = innerDivID;

    $('close').addEvent('click', function(event){
            removeFloatingBox(content, 'advert');
    });
}

function removeFloatingBox(){

    if(myWin){
        $(myWin).set('opacity', 0);
        $('FloatBoxWrapper').innerHTML = '';
        $('FloatBoxWrapper').className = '';
        $('FloatBoxWrapper').style.display = 'none';
        myWin = null;
    }
}

function submitForm(theForm, content){

    //alert("submitting form: " + theForm.id);
    // make the form disapear, and submit it
    theForm.submit();
    //theForm.style.display = 'none';



    // TODO -> Fix this in Chrome with preloading the image
   // $(theForm.id + "_div").set('html', $(theForm.id + "_div").get('html')+"<div class='large_loader'><img src='/static/images/large_loader.gif' alt='Loading' /></div>&nbsp;");

}

function submitMailChimp(theForm){

    // make the form disapear, and submit it
    theForm.submit();
    theForm.style.display = 'none';

    // TODO -> Fix this in Chrome with preloading the image
    $(theForm.name + "_div").set('html', $(theForm.name + "_div").get('html')+"<div class='mailchimp_sent'><center><h3>Subscription request sent!</h3><p>Thank you!</p></center></div>&nbsp;");

}

function initPlaynowButtons(){

    $('playnow_button_container').getElements('div.playnow_button').addEvents({
        mouseenter: function(){
            this.style.backgroundImage = 'none';
            this.style.backgroundColor = '#333333'; //'#520222';//ff5959';
            this.style.color = '#ffffff';//'#fafafa';

            var ps = this.getElements('p.playnow_button_star_rating');
            //for(p in ps){
                //p.style.visibility = 'visible';
                ps[0].setStyle('visibility', 'visible');
            //}
        },
        mouseleave: function(){
            this.style.backgroundImage = 'url(/static/images/playnow/sprite_medium.jpeg)';
            this.style.color = 'transparent';

            var ps = this.getElements('p.playnow_button_star_rating');
            //for(p in ps){
                ps[0].setStyle('visibility', 'hidden');
            //}
        }
    });
}

function getPlaynowPage(page){

    var theUrl = "/playnow/"+page;

    doServerRequest(theUrl, "playnow_button_listing");
}

function doRating(thisid, id, rating){
    var theUrl = $(thisid).href;
    doServerRequest(theUrl, "rating_div_" + id);
}


function doServerRequest(theURL, DivID){

    //alert("in doServerRequest with " + theURL + ", " + DivID);
    var splitArray = theURL.split('?');
    var URL = splitArray[0];
    var params = splitArray[1] + "&ajax=1";
    
    var request = new Request.HTML({
			method: 'post',
			url: URL,
			onRequest: function() { getSpinnerContent(DivID); },
            onComplete: function(response) {},
			update: $(DivID),
            noCache: true
		});
    request.send(params);
}

function doServerRequestWithFunc(theURL, DivID, func){

    //alert("in doServerRequestWithFunc with: " + theURL);
    var splitArray = theURL.split('?');
    var URL = splitArray[0];
    var params = splitArray[1] + "ajax=1";
    
    var request = new Request.HTML({
			method: 'post',
			url: URL,
			onRequest: function() { getSpinnerContent(DivID); },
            onComplete: function(response) { func(); },
			update: $(DivID)
		});
    request.send(params);
}

function doServerRequestNoReturn(theURL){

    //alert("in doServerRequestNoReturn with: " + theURL);
    var splitArray = theURL.split('?');
    var URL = splitArray[0];
    var params = splitArray[1];
    
    var request = new Request.HTML({
			method: 'post',
			url: URL
		});
    request.send(params);
}

function getSpinnerContent(DivID){

    var spinnerContent = "<div class='loading'><img src='/static/images/spinner.gif' alt='Please Wait' /></div>";

    if(/rating_div_(\d+)/.test(DivID)){
        spinnerContent = "<div class='star_loading'><img src='/static/images/star_loader_custom.gif' alt='Please wait' /></div>";
    }else if(/_tab_/.test(DivID)){
        spinnerContent = "<div class='tab_loading'><img src='/static/images/large_loader.gif' alt='Please Wait' /></div>";
    }

    var elems = $(DivID);
    elems.style.display = '';        
    elems.innerHTML = spinnerContent;
}


function send_feedback(path, id_addition){
    var theUrl = url + path + "?message=" + encodeURIComponent($('feedback_message'+id_addition).value) + "&id_addition=" + id_addition;
    if($('feedback_email'+id_addition)){
        theUrl = theUrl + "&email=" + $('feedback_email'+id_addition).value;
    }

    doServerRequest(theUrl, 'feedback_tab_container'+id_addition);
}


//-->

