
//<!--


// Game variables
var crosswordWidthHeight = 15;
var crosswordDirection = "left2right";
var sudokuWidthHeight = 9;
var sudokuDirection = "left2right";
var bubble_count = 0;

function initCrossword(){
    var idRegExp = /x(\d+)y(\d+)/i;

    for(var i = 1;  i <= crosswordWidthHeight; i++){
        for(var j = 1;  j <= crosswordWidthHeight; j++){
            var theID = "x"+i+"y"+j;
            
            if($(theID)){

                $(theID).addEvent('focus', function(event){
                    event.stop();
                    this.select();
                    if(crosswordDirection == 'left2right'){
                        this.className = 'activel2r';
                    }else{
                        this.className = 'activet2b';
                    }
                });
                $(theID).addEvent('blur', function(event){
                    event.stop();
                    this.className = 'letter';
                });
                $(theID).addEvent('keydown', function(event){
                    var keypressed = event.key.toLowerCase();
                    if(keypressed == 'tab'){
                        return true;
                    }

                    event.stop();

                    moveFocusCrossword(keypressed, this.id, idRegExp);
                    return true;
                    
                });
            }            
        }
    }
}

// For the usibility extras on the crosswords
function moveFocusCrossword(keypressed, thisID, idRegExp){

    if(keypressed == 'down' && crosswordDirection == 'left2right'){
        crosswordDirection = 'top2bottom';
        $(thisID).className = 'activet2b';
        crosswordDirection = 'top2bottom';
        return;
    }else if(keypressed == 'right' && crosswordDirection == 'top2bottom'){
        $(thisID).className = 'activel2r';
        crosswordDirection = 'left2right';
        return;
    }

    var way_to_go = keypressed;
    if(/[a-z]/.test(keypressed) && keypressed.length == 1){
        if(crosswordDirection == 'left2right'){
            way_to_go = 'right';
        }else{
            way_to_go = 'down';
        }

        $(thisID).value = keypressed;
    }

    // Get the x & y from the input's id
    var found = thisID.match( idRegExp );
    var thisx = parseInt(found[1]); 
    var thisy = parseInt(found[2]);

    switch (way_to_go) {
        case 'up':
            // decrease y
            crosswordDirection = 'top2bottom';
            var x = thisx;
            var y = thisy-1;
            var nextID = "x"+x+"y"+y;
            if($(nextID)){
                $(nextID).focus();
            }else{
                while(y > 1){
                    y = y-1;
                    nextID = "x"+x+"y"+y;
                    if($(nextID)){
                        $(nextID).focus();
                        break;
                    }
                }
            }    
            break;
        case 'right':
            // increase x
            crosswordDirection = 'left2right';
            var x = thisx+1;
            var y = thisy;
            var nextID = "x"+x+"y"+y;
            if($(nextID)){
                $(nextID).focus();
            }else{
                while(x < crosswordWidthHeight){
                    x = x+1
                    nextID = "x"+x+"y"+y;
                    if($(nextID)){
                        $(nextID).focus();
                        break;
                    }
                }
            }
            break;
        case 'down':
            // increase y
            crosswordDirection = 'top2bottom';
            var x = thisx;
            var y = thisy+1;
            var nextID = "x"+x+"y"+y;
            if($(nextID)){
                $(nextID).focus();
            }else{
                while(y < crosswordWidthHeight){
                    y = y+1;
                    nextID = "x"+x+"y"+y;
                    if($(nextID)){
                        $(nextID).focus();
                        break;
                    }
                }
            }
            break;
        case 'left':
            // decrease x
            crosswordDirection = 'left2right';
            var x = thisx-1;
            var y = thisy;
            var nextID = "x"+x+"y"+y;
            if($(nextID)){
                $(nextID).focus();
            }else{
                while(x > 1){
                    x = x-1;
                    nextID = "x"+x+"y"+y;
                    if($(nextID)){
                        $(nextID).focus();
                        break;
                    }
                }
            }
            break;
        default:
            // Don't move focus
            break;
    }
}

function initSudoku(){
    var idRegExp = /x(\d+)y(\d+)/i;

    for(var i = 1;  i <= sudokuWidthHeight; i++){
        for(var j = 1;  j <= sudokuWidthHeight; j++){
            var theID = "x"+i+"y"+j;
            
            if($(theID)){

                $(theID).addEvent('focus', function(event){
                    event.stop();
                    this.select();
                    if(sudokuDirection == 'left2right'){
                        this.className = 'activel2r';
                    }else{
                        this.className = 'activet2b';
                    }
                });
                $(theID).addEvent('blur', function(event){
                    event.stop();
                    this.className = 'number';
                });
                $(theID).addEvent('keydown', function(event){
                    var keypressed = event.key.toLowerCase();
                    if(keypressed == 'tab'){
                        return true;
                    }

                    event.stop();

                    moveFocusSudoku(keypressed, this.id, idRegExp);
                    return true;
                    
                });
            }            
        }
    }
}

// For the usibility extras on the crosswords
function moveFocusSudoku(keypressed, thisID, idRegExp){

    if(keypressed == 'down' && sudokuDirection == 'left2right'){
        sudokuDirection = 'top2bottom';
        $(thisID).className = 'activet2b';
        sudokuDirection = 'top2bottom';
        return;
    }else if(keypressed == 'right' && sudokuDirection == 'top2bottom'){
        $(thisID).className = 'activel2r';
        sudokuDirection = 'left2right';
        return;
    }

    var way_to_go = keypressed;
    if(/[1-9]/.test(keypressed) && keypressed.length == 1){
        if(sudokuDirection == 'left2right'){
            way_to_go = 'right';
        }else{
            way_to_go = 'down';
        }

        $(thisID).value = keypressed;
    }

    // Get the x & y from the input's id
    var found = thisID.match( idRegExp );
    var thisx = parseInt(found[1]); 
    var thisy = parseInt(found[2]);

    switch (way_to_go) {
        case 'up':
            // decrease y
            sudokuDirection = 'top2bottom';
            var x = thisx;
            var y = thisy-1;
            var nextID = "x"+x+"y"+y;
            if($(nextID)){
                $(nextID).focus();
            }else{
                while(y > 1){
                    y = y-1;
                    nextID = "x"+x+"y"+y;
                    if($(nextID)){
                        $(nextID).focus();
                        break;
                    }
                }
            }    
            break;
        case 'right':
            // increase x
            sudokuDirection = 'left2right';
            var x = thisx+1;
            var y = thisy;
            var nextID = "x"+x+"y"+y;
            if($(nextID)){
                $(nextID).focus();
            }else{
                while(x < sudokuWidthHeight){
                    x = x+1
                    nextID = "x"+x+"y"+y;
                    if($(nextID)){
                        $(nextID).focus();
                        break;
                    }
                }
            }
            break;
        case 'down':
            // increase y
            sudokuDirection = 'top2bottom';
            var x = thisx;
            var y = thisy+1;
            var nextID = "x"+x+"y"+y;
            if($(nextID)){
                $(nextID).focus();
            }else{
                while(y < sudokuWidthHeight){
                    y = y+1;
                    nextID = "x"+x+"y"+y;
                    if($(nextID)){
                        $(nextID).focus();
                        break;
                    }
                }
            }
            break;
        case 'left':
            // decrease x
            sudokuDirection = 'left2right';
            var x = thisx-1;
            var y = thisy;
            var nextID = "x"+x+"y"+y;
            if($(nextID)){
                $(nextID).focus();
            }else{
                while(x > 1){
                    x = x-1;
                    nextID = "x"+x+"y"+y;
                    if($(nextID)){
                        $(nextID).focus();
                        break;
                    }
                }
            }
            break;
        default:
            // Don't move focus
            break;
    }
}

function changeCrosswordClue(clueID, theCheckbox, isTopClue, isBottomClue){

    var clueDivID = "clue" + clueID;
    if(theCheckbox.checked == true){        
        if(isTopClue){
            $(clueDivID).className = "topclue deadclue";
        }else if(isBottomClue){
            $(clueDivID).className = "bottomclue deadclue";
        }else{
            $(clueDivID).className = "clue deadclue";
        }
    }else{
        if(isTopClue){
            $(clueDivID).className = "topclue";
        }else if(isBottomClue){
            $(clueDivID).className = "bottomclue";
        }else{
            $(clueDivID).className = "clue";
        }
    }
}



function pauseTimer(){
    timer.pause();
}
function resumeTimer(){
    timer.start();
}
function pauseGame(){

    if(! /\?ajax=1/.test($('game_pause').href)){
        $('game_pause').href = $('game_pause').href + "?ajax=1";
    }
    
    pauseTimer();
}
function closeGamePause(){
    top.pauseMultibox.close();
}

function resumeGame(){
    
    var request = new Request.HTML({
			method: 'post',
			url: $('game_resume').href,
            noCache: true
		});
    request.send("ajax=1");

    resumeTimer();
}

var GameTimer = new Class({

    Implements: [Options],
    
	options: {
		startCrono: '00:00:00',
		div: false,
        direction : 'forward',
        onZero: function(){ }
	},
	initialize: function(options){
        this.setOptions(options);
		this.state = 'stopped';
		this.reset();
	},
	start: function() {
		if (this.state != 'running') {
			this.timer = this.count.periodical(1000,this); 
			this.state = 'running';
		}
	},
	pause: function() { 
		if (this.state != 'paused') {
			$clear(this.timer); 
			this.state = 'paused';
		}
	},
	count: function(){

        if(this.options.direction == 'forward'){
             this.sec += 1;
		
    		if (this.sec == 60) {
    			this.sec = 0;
    			this.min += 1;
    		}
    
            if (this.min == 60) {
    			this.min = 0;
    			this.hour += 1;
    		}
        }else{
            this.sec -= 1;

		
    		if (this.sec == -1) {

                if(this.min == 0 && this.hour == 0){
                    // Stop the timer, it's at zero!
                    $clear(this.timer); 
                    this.state = 'stopped';
                    this.sec = 0;
                    this.options.onZero();
                }else{
                    this.sec = 59;
                    this.min -= 1;
                }    			
    		}
    
            if (this.min == -1) {
    			this.min = 59;
    			this.hour -= 1;
    		}
        }
	
		if (this.options.div != false);
			$(this.options.div).innerHTML = this.time();

	},
	time: function() {
		time_to_show = (this.hour < 10) ? "0" + this.hour : this.hour;
		time_to_show += ((this.min < 10) ? ":0" : ":") + this.min;
        time_to_show += ((this.sec < 10) ? ":0" : ":") + this.sec;
		return time_to_show;
	},
    reset: function(){
		//reset time to initial values
		start_array = this.options.startCrono.split(":");

        this.startHour = parseInt(start_array[0]);
		this.startMin = parseInt(start_array[1]);
		this.startSec = parseInt(start_array[2]);

        this.hour = this.startHour;
		this.min = this.startMin;
		this.sec = this.startSec;

		if (this.options.div != false);
			$(this.options.div).innerHTML = this.time();
	}
});


// Admin

function initAdmin(){
    var images = ['/static/images/large_loader.gif'];
    var image = new Image();
    
    var ln = images.length;
    for(var x = 0; x < ln; x++) {
        image.src = images[x];
    }
}

function initAdminCrossword(){
    // add ajax events to all the checkmark buttons

    //alert("in initAdminCrossword");

    var change_clues = $$('a[title=change_clue]');
    var ln = change_clues.length;
    for(var i = 0; i < ln; i++){
        change_clues[i].addEvent('click', function(event){
            event.stop();

            adminChangeCrosswordClue(this.id);
        });
    }
    
    var use_clues = $$('a[title=use_clue]');
    var ln = use_clues.length;
    for(var i = 0; i < ln; i++){
        use_clues[i].addEvent('click', function(event){
            event.stop();
            adminUseCrosswordClue(this.id);
        });
    }
}

function adminChangeCrosswordClue(thisid){

    //alert("in adminChangeCrosswordClue with " + thisid);
    var div = thisid + "_div";
    var idRegExp = /change_clue_(\d+)/i;
    var found = thisid.match( idRegExp );
    var clue_id = found[1]; 
    var theUrl = $(thisid).href + "?clue=" + $("clue_"+clue_id).value;
    
    doServerRequest(theUrl, div);
}
function adminUseCrosswordClue(thisid){

    //alert("in adminUseCrosswordClue with " + thisid);
    var div = thisid + "_div";
    var idRegExp = /use_clue_(\d+)_(\d+)/i;
    var found = thisid.match( idRegExp );
    var clue_id = found[1]; 
    var dict_clue_id = found[2]; 
    $("clue_"+clue_id).value = $(thisid + "_span").innerHTML;
    var theUrl = $(thisid).href;
    
    doServerRequest(theUrl, div);
}

function adminSetPlayDate(thisid){

    //alert("in adminSetCrosswordPlayDate with " + thisid);
    var div = thisid + "_div";
    var idRegExp = /set_played_date_button_(\d+)/i;
    var found = thisid.match( idRegExp );
    var crossword_id = found[1]; 
    var theUrl = $(thisid).href + "?the_play_date=" + $('play_date').value;
    
    doServerRequest(theUrl, div);
}

function initAdminAdverts(){
    var preview_buttons = $$('a[title=ad_preview_button]');
    
    var ln = preview_buttons.length;
    for(var i = 0; i < ln; i++){
    
        preview_buttons[i].addEvent('click', function(event){
            event.stop();
            var id = this.id;
            var idRegExp = /ad_preview_button_(\d+)/i;
            var found = id.match( idRegExp );
            var ad_id = found[1]; 

            var content = $("ad_code_"+ad_id).value;
            showFloatingBox(content, 'advert');
        });
    }
}

function initAdminKeywordTable(keyword_table_div, small){

    if(keywords.length == 0){
        return
    }

    var headers = ['&nbsp;', 'Keyword', 'Demand', 'Supply', 'Profitability', 'CPC', 'Keyworth']; 
    if(small){
        headers = ['Keyword', 'Demand', 'Supply', 'Profitability', 'CPC']; 
    }

    keyword_table = new HtmlTable({
        properties: {
        },
        headers: headers,
        rows: keywords,
        zebra:true,
        classZebra: 'keyword_table_odd',
        sortable:true, 
        sortIndex: 3,
        sortReverse: true,
        classHeadSort: '^^&#9650;',
        classHeadSortRev: '&#9660;'
    });

    keyword_table.inject($(keyword_table_div));

    $('keyword_count').innerHTML = keywords.length + " keywords";

    if($('keyword_filter')){
        $('keyword_filter').addEvent('keyup', function(event){
    
            var is_letter = /\w/.test(event.key);
    
            //alert("key: " + event.key);
    
            if (is_letter || event.key == 'space' || event.key == 'backspace') {
    
                if($('keyword_filter').value.length >= 1){
    
                    //filter through the keyword array and rebuild the table with on those that match
                    var new_keyword_list_primary = new Array();
                    var new_keyword_list_secondary = new Array();
    
                    var at_front_regex = new RegExp("^" + $('keyword_filter').value);
                    var in_word_regex = new RegExp($('keyword_filter').value);
    
                    for(var i = 0; i < keywords.length; i++){
                        var keyword = keywords[i][0];
    
                        if(at_front_regex.test(keyword)){
                            new_keyword_list_primary.push(keywords[i]);
                        }else if(in_word_regex.test(keyword)){
                            new_keyword_list_secondary.push(keywords[i]);
                        }
                    }
    
                    //new_keyword_list_primary.concat(new_keyword_list_secondary);
                    keyword_table.empty();
    
                    for(var i = 0; i < new_keyword_list_primary.length; i++){
                        var keyword = new_keyword_list_primary[i];
                        keyword_table.push(keyword);
                    }
    
                    for(var i = 0; i < new_keyword_list_secondary.length; i++){
                        var keyword = new_keyword_list_secondary[i];
                        keyword_table.push(keyword);
                    }
                }else{
                   for(var i = 0; i < keywords.length; i++){
                        var keyword = keywords[i];
                        keyword_table.push(keyword);
                    }
                }
            }else{
                $('keyword_filter').value = "";
            }
    
            $('keyword_count').innerHTML = new_keyword_list_primary.length + new_keyword_list_secondary.length + " keywords";
        });
    }
}

function adminChangeKeywordsImport(){
    var keyword;
    var import_id = $('which_import').getSelected()[0].value;
    
    // Send request to get keywords, empty table and refresh
    if(keyword_lists[import_id]){
        keyword_table.empty();
        var keywords = keyword_lists[import_id] ;
        var length = keywords.length; 
        for (var i = 0; i < length; i++) {
            keyword_table.push(keywords[i]);
        }
        $('keyword_count').innerHTML = keywords.length + " keywords";
    }else{
        var request = new Request.JSON({
            method: 'post',
            url: url + "/admin/keywords/keywords/"+import_id,
            onSuccess: function(responseJSON, responseText) {
                           keywords = responseJSON['keywords'];
                           keyword_lists[import_id] = keywords; 
                           keyword_table.empty();
                           var length = keywords.length; 
                           for (var i = 0; i < length; i++) {
                               keyword = keywords[i];
                               keyword_table.push(keyword);
                           }
                           $('keyword_count').innerHTML = keywords.length + " keywords";
                },
            onFailure: function(xhr){
                            alert("An error occured in retreiving your keywords! ");
                },
            noCache: true
        });
        request.send("ajax=1");
    }
}

function asociateCategories(){

    var selected_categories = $('c').getSelected();
    var categories = "";
    for (var i = 0; i < selected_categories.length; i++) {
        if(categories == ""){
            categories = selected_categories[i].value;
        }else{
            categories = categories + "," + selected_categories[i].value;
        }
        
    }
    var theUrl = $('associate_categories_button').href + "?t=" + $('t').value + "&i=" + $('i').value + "&c=" + categories;
    doServerRequest(theUrl, 'admin_associate_categories_container');
}    


function changeBubbleArrowKeys(keypressed, thisid){ /* Admin function */

    var idRegExp = /bubble_info_input_(\w+)_(\d+)/;
    var found = thisid.match( idRegExp );
    var changeType = found[1]; 
    var bubble_count = parseInt(found[2]); 
    
    var inputToChange = $('bubble_'+bubble_count);
    

    if(keypressed == "down"){
        var valueToChangeTo = parseInt($(thisid).value) - 1;
        $(thisid).value = valueToChangeTo;
        switch (changeType) {
            case 'width':                
                inputToChange.style.width = valueToChangeTo + "px";
                break;
            case 'height':
                inputToChange.style.height = valueToChangeTo + "px";
                break;
            case 'top':
                inputToChange.style.top = valueToChangeTo + "px";
                break;
            case 'left':
                inputToChange.style.left = valueToChangeTo + "px";
                break;
            case 'fontsize':
                inputToChange.style.fontSize = valueToChangeTo + "px";
                break;
        }
    }else if(keypressed == "up"){
        var valueToChangeTo = parseInt($(thisid).value) + 1;
        $(thisid).value = valueToChangeTo;
        switch (changeType) {
            case 'width':                
                inputToChange.style.width = valueToChangeTo + "px";
                break;
            case 'height':
                inputToChange.style.height = valueToChangeTo + "px";
                break;
            case 'top':
                inputToChange.style.top = valueToChangeTo + "px";
                break;
            case 'left':
                inputToChange.style.left = valueToChangeTo + "px";
                break;
            case 'fontsize':
                inputToChange.style.fontSize = valueToChangeTo + "px";
                break;
        }
    }

    return;
}

function changeBubbleValue(thisid){ /* Admin function */

    var idRegExp = /bubble_info_input_(\w+)_(\d+)/;
    var found = thisid.match( idRegExp );
    var changeType = found[1]; 
    var bubble_count = found[2]; 
    
    var valueToChangeTo;
    if(changeType != "background" && changeType != "border" && changeType != "font" && changeType != "customcss" ){
        valueToChangeTo = parseInt($(thisid).value) - 1;
    }else{
        valueToChangeTo = $(thisid).value;
    }
    var inputToChange = $('bubble_'+bubble_count);

    switch (changeType) {
        case 'width':
            inputToChange.setStyle('width', valueToChangeTo + "px");
            break;
        case 'height':
            inputToChange.setStyle('height', valueToChangeTo + "px");
            break;
        case 'top':
            inputToChange.setStyle('top', valueToChangeTo + "px");
            break;
        case 'left':
            inputToChange.setStyle('left', valueToChangeTo + "px");
            break;
        case 'background':
            inputToChange.setStyle('background', valueToChangeTo);
            break;  
        case 'border':
            inputToChange.setStyle('border', valueToChangeTo);
            break;
        case 'font':
            inputToChange.setStyle('fontFamily', valueToChangeTo);
            break;
        case 'fontsize':
            inputToChange.setStyle('fontSize', valueToChangeTo + "px");
            break;
        case 'customcss':
            var css_rules = valueToChangeTo.split(';');

            var css_map = new Object(); 
            var ln = css_rules.length;
            for (var i = 0; i < ln; i++) {
                var css_pieces = css_rules[i].split(':');
                css_map[css_pieces[0]] = css_pieces[1];
                
                //alert("css_pieces[0]: " + css_pieces[0] + ", css_pieces[1]: " + css_pieces[1]);
            }

            //for (var thing in css_map){
            //   alert("css: " + thing + " " + css_map[thing]);
            //}

            inputToChange.setStyles(css_map);
            break;
    }
}

function addCaptionBubble(thisid){ /* Admin function */

    bubble_count++;
    $('admin_caption_image').innerHTML = $('admin_caption_image').innerHTML + 
                                         "<textarea class='caption_bubble_textarea' id='bubble_"+bubble_count+"'></textarea>";

    var new_div = new Element('div', {'id': 'bubble_info_wrapper_' + bubble_count});
    new_div.inject($('bubble_wrapper'), 'top');

    $('save_bubbles_button').setStyle('display', 'inline-block');    
    $('add_bubble_button').href = "/admin/games/caption/add_bubble/" + bubble_count;
    var theUrl = $(thisid).href + "?bubble_count=" + bubble_count;
    doServerRequest(theUrl, 'bubble_info_wrapper_' + bubble_count);
    
}

function initAdminCaption(){
    $('add_bubble_button').addEvent('click', function(event){
        event.stop();
        addCaptionBubble(this.id);
    });
}

function chooseWord(word_id){
    $('word').value = $('word_id_'+word_id).innerHTML;
    $('dict_word_id').value = word_id;
}

function toggleReleasable(t, id){

    var theUrl = "/admin/"+t+"/toggle_releasable/"+id;
    if($('toggle_releasable_button').className == t+'_releasable'){
        $('toggle_releasable_button').className = t+'_not_releasable';
    }else{
        $('toggle_releasable_button').className = t+'_releasable';
    }

    doServerRequestNoReturn(theUrl);
}

var ad_div = 'advert';
var ad_pos = 0;
function switchAd(response){

    $('hiddenadvert').set('html', response);
    
    $(ad_div).fade('hide').set('html', response).fade('in');
    ad_pos = ad_pos + 1;

    setTimeout ( 'getAdvert()', ad_seconds);
}
function getAdvert(){

    theurl = url + "/adverts/get/"+$(ad_div+"_wrap").getStyle('width')+"/"+$(ad_div+"_wrap").getStyle('height')+"/"+ad_pos;
     
    var request = new Request({
			method: 'get',
			url: theurl,
            onComplete: function(response) { switchAd(response) },
            evalScripts: true,
            noCache: true
		});
    request.send();
}

var values_present = 0;
var inputs = new Array('aa', 'bb', 'cc', 'dd');
function cross_multiply_divide(){                    
    var values = new Object;
    values_present = 0;
    for (var i = 0; i < inputs.length; i++) {
        if($(inputs[i]).value){
            if($(inputs[i]).value.match(/^\d+$/)){
                values[inputs[i]] = $(inputs[i]).value;
                values_present++;
            }else{
                $(inputs[i]).value = '';
                values_present--;
            }
        }
    }

    if(values_present == 3){
        if(values['aa'] && values['dd']){
            if(values['bb']){
                $('dd').value = values['aa'] * values['dd'] / values['bb'];
            }else if(values['cc']){
                $('bb').value = values['aa'] * values['dd'] / values['cc'];
            }
        }else if(values['bb'] && values['cc']){
            if(values['aa']){
                $('dd').value = (values['bb'] * values['cc']) / values['aa'];
            }else if(values['dd']){
                $('aa').value = values['bb'] * values['cc'] / values['dd'];
            }
        }
    }
};
function clear_cross_multiply_divide_inputs(){
    for (var i = 0; i < inputs.length; i++) {
        $(inputs[i]).value = '';
    }
    values_present = 0;
};

function blockWord(url){
    var theUrl = url + "?words=" + $('words').value;
    doServerRequest(theUrl, 'block_word_div');
}

//-->
