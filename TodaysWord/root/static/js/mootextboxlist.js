
/*
Script: TextboxList.js
	Displays a textbox as a combination of boxes an inputs (eg: facebook tokenizer)

	Authors:
		Guillermo Rauch
		
	Note:
		TextboxList is not priceless for commercial use. See <http://devthought.com/projects/mootools/textboxlist/>. 
		Purchase to remove this message.
*/

var TextboxList = new Class({
          
  Implements: [Options, Events],

  plugins: [],

  options: {/*
    onFocus: $empty,
    onBlur: $empty,
    onBitFocus: $empty,
    onBitBlur: $empty,
    onBitAdd: $empty,
    onBitRemove: $empty,
    onBitBoxFocus: $empty,
    onBitBoxBlur: $empty,
    onBitBoxAdd: $empty,
    onBitBoxRemove: $empty,
    onBitEditableFocus: $empty,
    onBitEditableBlue: $empty,
    onBitEditableAdd: $empty,
    onBitEditableRemove: $empty,*/
    prefix: 'textboxlist',
    max: null,
		unique: false,
		uniqueInsensitive: true,
    endEditableBit: true,
		startEditableBit: true,
		hideEditableBits: true,
    inBetweenEditableBits: true,
		keys: {previous: Event.Keys.left, next: Event.Keys.right},
		bitsOptions: {editable: {}, box: {}},
    plugins: {},
		check: function(s){ return s.clean().replace(/,/g, '') != ''; },
		encode: function(o){ 
			return o.map(function(v){				
				v = ($chk(v[0]) ? v[0] : v[1]);
				return $chk(v) ? v : null;
			}).clean().join(','); 
		},
		decode: function(o){ return o.split(','); }
  },
  
  initialize: function(element, options){
		this.setOptions(options);		
		this.original = $(element).setStyle('display', 'none').set('autocomplete', 'off').addEvent('focus', this.focusLast.bind(this));
    this.container = new Element('div', {'class': this.options.prefix}).inject(element, 'after');
		this.container.addEvent('click', function(e){ 
			if ((e.target == this.list || e.target == this.container) && (!this.focused || $(this.current) != this.list.getLast())) this.focusLast(); 			
		}.bind(this));
    this.list = new Element('ul', {'class': this.options.prefix + '-bits'}).inject(this.container);		
		for (var name in this.options.plugins) this.enablePlugin(name, this.options.plugins[name]);		
		['check', 'encode', 'decode'].each(function(i){ this.options[i] = this.options[i].bind(this); }, this);
		this.afterInit();
  },

	enablePlugin: function(name, options){
		this.plugins[name] = new TextboxList[name.camelCase().capitalize()](this, options);
	},
	
	afterInit: function(){
		if (this.options.unique) this.index = [];
		if (this.options.endEditableBit) this.create('editable', null, {tabIndex: this.original.tabIndex}).inject(this.list);
		var update = this.update.bind(this);
		this.addEvent('bitAdd', update, true).addEvent('bitRemove', update, true);
		document.addEvents({
			click: function(e){
				if (!this.focused) return;
				if (e.target.className.contains(this.options.prefix)){
					if (e.target == this.container) return;
					var parent = e.target.getParent('.' + this.options.prefix);
					if (parent == this.container) return;
				}
				this.blur();
			}.bind(this),
			keydown: function(ev){
				if (!this.focused || !this.current) return;
				var caret = this.current.is('editable') ? this.current.getCaret() : null;
				var value = this.current.getValue()[1];
				var special = ['shift', 'alt', 'meta', 'ctrl'].some(function(e){ return ev[e]; });
				var custom = special || (this.current.is('editable') && this.current.isSelected());
				switch (ev.code){
					case Event.Keys.backspace:
						if (this.current.is('box')){ 
							ev.stop();
							return this.current.remove(); 
						}
					case this.options.keys.previous:
						if (this.current.is('box') || ((caret == 0 || !value.length) && !custom)){
							ev.stop();
							this.focusRelative('previous');
						}
						break;
					case Event.Keys['delete']:
						if (this.current.is('box')){ 
							ev.stop();
							return this.current.remove(); 
						}
					case this.options.keys.next: 
						if (this.current.is('box') || (caret == value.length && !custom)){
							ev.stop();
							this.focusRelative('next');
						}
				}
			}.bind(this)
		});		
		this.setValues(this.options.decode(this.original.get('value')));
	},
	
	create: function(klass, value, options){
		if (klass == 'box'){
			if ((!value[0] && !value[1]) || ($chk(value[1]) && !this.options.check(value[1]))) return false;
			if ($chk(this.options.max) && this.list.getChildren('.' + this.options.prefix + '-bit-box').length + 1 > this.options.max) return false;
			if (this.options.unique && this.index.contains(this.uniqueValue(value))) return false;		
		}		
		return new TextboxListBit[klass.capitalize()](value, this, $merge(this.options.bitsOptions[klass], options));		
	},
	
	uniqueValue: function(value){
		return $chk(value[0]) ? value[0] : (this.options.uniqueInsensitive ? value[1].toLowerCase() : value[1]);
	},
	
	onFocus: function(bit){
		if (this.current) this.current.blur();
		$clear(this.blurtimer);
		this.current = bit;
		this.container.addClass(this.options.prefix + '-focus');
		if (!this.focused){
			this.focused = true;
			this.fireEvent('focus', bit);
		}
	},
	
	onBlur: function(bit, all){
		this.current = null;
		this.container.removeClass(this.options.prefix + '-focus');		
		this.blurtimer = this.blur.delay(all ? 0 : 200, this);
	},
	
	onAdd: function(bit){
		if (this.options.unique && bit.is('box')) this.index.push(this.uniqueValue(bit.value));
		if (bit.is('box')){
			var prior = this.getBit($(bit).getPrevious());
			if ((prior && prior.is('box') && this.options.inBetweenEditableBits) || (!prior && this.options.startEditableBit)){				
				var b = this.create('editable').inject(prior || this.list, prior ? 'after' : 'top');
				if (this.options.hideEditableBits) b.hide();
			}
		}
	},
	
	onRemove: function(bit){
		if (!this.focused) return;
		if (this.options.unique && bit.is('box')) this.index.erase(this.uniqueValue(bit.value));
		var prior = this.getBit($(bit).getPrevious());
		if (prior && prior.is('editable')) prior.remove();
		this.focusRelative('next', bit);
	},
	
	focusRelative: function(dir, to){
		var b = this.getBit($($pick(to, this.current))['get' + dir.capitalize()]());
		if (b) b.focus();
		return this; 
	},
	
	focusLast: function(){		
		var lastElement = this.list.getLast();
		if (lastElement) this.getBit(lastElement).focus();
		return this;
	},
	
	blur: function(){		
		if (! this.focused) return this;
		if (this.current) this.current.blur();
		this.focused = false;
		return this.fireEvent('blur');
	},
	
	add: function(plain, id, html, afterEl){
		var b = this.create('box', [id, plain, html]);
		if (b){
			if (!afterEl) afterEl = this.list.getLast('.' + this.options.prefix + '-bit-box');
			b.inject(afterEl || this.list, afterEl ? 'after' : 'top');
		}
		return this;
	},
	
	getBit: function(obj){
		return ($type(obj) == 'element') ? obj.retrieve('textboxlist:bit') : obj;
	},
	
	getValues: function(){
		return this.list.getChildren().map(function(el){
			var bit = this.getBit(el);
			if (bit.is('editable')) return null;
			return bit.getValue();
		}, this).clean();
	},
	
	setValues: function(values){
		if (!values) return;
		values.each(function(v){
			if (v) this.add.apply(this, $type(v) == 'array' ? [v[1], v[0], v[2]] : [v]);
		}, this);		
	},
	
	update: function(){
		this.original.set('value', this.options.encode(this.getValues()));
	}
  
});

var TextboxListBit = new Class({
  
  Implements: Options,  

  initialize: function(value, textboxlist, options){
		this.name = this.type.capitalize();
		this.value = value;
    this.textboxlist = textboxlist;
    this.setOptions(options);            
    this.prefix = this.textboxlist.options.prefix + '-bit';
		this.typeprefix = this.prefix + '-' + this.type;
    this.bit = new Element('li').addClass(this.prefix).addClass(this.typeprefix).store('textboxlist:bit', this);
		this.bit.addEvents({
			mouseenter: function(){ 
				this.bit.addClass(this.prefix + '-hover').addClass(this.typeprefix + '-hover'); 
			}.bind(this),
			mouseleave: function(){
				this.bit.removeClass(this.prefix + '-hover').removeClass(this.typeprefix + '-hover'); 
			}.bind(this)
		});
  },

	inject: function(element, where){
		this.bit.inject(element, where);	
		this.textboxlist.onAdd(this);	
		return this.fireBitEvent('add');
	},

	focus: function(){
		if (this.focused) return this;
		this.show();
		this.focused = true;
		this.textboxlist.onFocus(this);
		this.bit.addClass(this.prefix + '-focus').addClass(this.prefix + '-' + this.type + '-focus');
		return this.fireBitEvent('focus');
	},

	blur: function(){
		if (!this.focused) return this;
		this.focused = false;
		this.textboxlist.onBlur(this);
		this.bit.removeClass(this.prefix + '-focus').removeClass(this.prefix + '-' + this.type + '-focus');
		return this.fireBitEvent('blur');
	},
	
	remove: function(){
		this.blur();		
		this.textboxlist.onRemove(this);
		this.bit.destroy();
		return this.fireBitEvent('remove');
	},
	
	show: function(){
		this.bit.setStyle('display', 'block');
		return this;
	},
	
	hide: function(){
		this.bit.setStyle('display', 'none');
		return this;
	},
	
	fireBitEvent: function(type){
		type = type.capitalize();
		this.textboxlist.fireEvent('bit' + type, this).fireEvent('bit' + this.name + type, this);
		return this;
	},
	
  is: function(t){
    return this.type == t;
  },

	setValue: function(v){
		this.value = v;
		return this;
	},

	getValue: function(){
		return this.value;
	},

	toElement: function(){
		return this.bit;
	}
  
});

TextboxListBit.Editable = new Class({
  
	Extends: TextboxListBit,

  options: {
		tabIndex: null,
		growing: true,
		growingOptions: {},
		stopEnter: true,
		addOnBlur: false,
		addKeys: Event.Keys.enter
  },
  
  type: 'editable',
  
  initialize: function(value, textboxlist, options){
    this.parent(value, textboxlist, options);
    this.element = new Element('input', {type: 'text', 'class': this.typeprefix + '-input', autocomplete: 'off', value: this.value ? this.value[1] : ''}).inject(this.bit);		
		if ($chk(this.options.tabIndex)) this.element.tabIndex = this.options.tabIndex;
		if (this.options.growing) new GrowingInput(this.element, this.options.growingOptions);		
		this.element.addEvents({
			focus: function(){ this.focus(true); }.bind(this),
			blur: function(){
				this.blur(true);
				if (this.options.addOnBlur) this.toBox(); 
			}.bind(this)
		});
		if (this.options.addKeys || this.options.stopEnter){
			this.element.addEvent('keydown', function(ev){
				if (!this.focused) return;
				if (this.options.stopEnter && ev.code === Event.Keys.enter) ev.stop();
				if ($splat(this.options.addKeys).contains(ev.code)){
					ev.stop();
					this.toBox();
				}
			}.bind(this));
		}
  },

	hide: function(){
		this.parent();
		this.hidden = true;
		return this;
	},
  
	focus: function(noReal){
		this.parent();
		if (!noReal) this.element.focus();	
		return this;
	},
	
	blur: function(noReal){
		this.parent();
		if (!noReal) this.element.blur();
		if (this.hidden && !this.element.value.length) this.hide();
		return this;
	},
	
	getCaret: function(){
		if (this.element.createTextRange){
	    var r = document.selection.createRange().duplicate();		
	  	r.moveEnd('character', this.element.value.length);
	  	if (r.text === '') return this.element.value.length;
	  	return this.element.value.lastIndexOf(r.text);
	  } else return this.element.selectionStart;
	},
	
	getCaretEnd: function(){
		if (this.element.createTextRange){
			var r = document.selection.createRange().duplicate();
			r.moveStart('character', -this.element.value.length);
			return r.text.length;
		} else return this.element.selectionEnd;
	},
	
	isSelected: function(){
		return this.focused && (this.getCaret() !== this.getCaretEnd());
	},

	setValue: function(val){
		this.element.value = $chk(val[0]) ? val[0] : val[1];
		if (this.options.growing) this.element.retrieve('growing').resize();
		return this;
	},

	getValue: function(){
		return [null, this.element.value, null];
	},
	
	toBox: function(){
		var value = this.getValue();				
		var b = this.textboxlist.create('box', value);
		if (b){
			b.inject(this.bit, 'before');
			this.setValue([null, '', null])
			return b;
		}
		return null;
	}
	
});

TextboxListBit.Box = new Class({
  
	Extends: TextboxListBit,

  options: {
		deleteButton: true
  },
  
  type: 'box',
  
  initialize: function(value, textboxlist, options){
    this.parent(value, textboxlist, options);
		this.bit.set('html', $chk(this.value[2]) ? this.value[2] : this.value[1]);
		this.bit.addEvent('click', this.focus.bind(this));
		if (this.options.deleteButton){
			this.bit.addClass(this.typeprefix + '-deletable');
			this.close = new Element('a', {href: '#', 'class': this.typeprefix + '-deletebutton', events: {click: this.remove.bind(this)}}).inject(this.bit);
		}
		this.bit.getChildren().addEvent('click', function(e){ e.stop(); });
  }
  
});


/*
Script: TextboxList.Autocomplete.js
	TextboxList Autocomplete plugin

	Authors:
		Guillermo Rauch
	
	Note:
		TextboxList is not priceless for commercial use. See <http://devthought.com/projects/mootools/textboxlist/>
		Purchase to remove this message.
*/

(function(){

TextboxList.Autocomplete = new Class({
	
	Implements: Options,
	
	options: {
		minLength: 1,
		maxResults: 10,
		insensitive: true,
		highlight: true,
		highlightSelector: null,
		mouseInteraction: true,
		onlyFromValues: false,
		queryRemote: false,
		remote: {
			url: '',
			param: 'search',
			extraParams: {},
			loadPlaceholder: 'Please wait...'
		},
		method: 'standard',
		placeholder: 'Type to receive suggestions'
	},
	
	initialize: function(textboxlist, options){
		this.setOptions(options);
		this.textboxlist = textboxlist;
		this.textboxlist.addEvent('bitEditableAdd', this.setupBit.bind(this), true)
			.addEvent('bitEditableFocus', this.search.bind(this), true)
			.addEvent('bitEditableBlur', this.hide.bind(this), true)
			.setOptions({bitsOptions: {editable: {addKeys:[], stopEnter: false}}});
		if (Browser.Engine.trident) this.textboxlist.setOptions({bitsOptions: {editable: {addOnBlur: false}}});
		if (this.textboxlist.options.unique){
			this.index = [];
			this.textboxlist.addEvent('bitBoxRemove', function(bit){
				if (bit.autoValue) this.index.erase(bit.autoValue);
			}.bind(this), true);
		}
		this.prefix = this.textboxlist.options.prefix + '-autocomplete';
		this.method = TextboxList.Autocomplete.Methods[this.options.method];
		this.container = new Element('div', {'class': this.prefix}).setStyle('width', this.textboxlist.container.getStyle('width')).inject(this.textboxlist.container);
		if ($chk(this.options.placeholder) || this.options.queryServer) 
			this.placeholder = new Element('div', {'class': this.prefix+'-placeholder'}).inject(this.container);		
		this.list = new Element('ul', {'class': this.prefix + '-results'}).inject(this.container);
		this.list.addEvent('click', function(ev){ ev.stop(); });
		this.values = this.results = this.searchValues = [];
		this.navigate = this.navigate.bind(this);
	},
	
	setValues: function(values){
		this.values = values;
	},
	
	setupBit: function(bit){
		bit.element.addEvent('keydown', this.navigate, true).addEvent('keyup', function(){ this.search(); }.bind(this), true);
	},
		
	search: function(bit){
		if (bit) this.currentInput = bit;
		if (!this.options.queryRemote && !this.values.length) return;
		var search = this.currentInput.getValue()[1];
		if (search.length < this.options.minLength) this.showPlaceholder(this.options.placeholder);
		if (search == this.currentSearch) return;
		this.currentSearch = search;
		this.list.setStyle('display', 'none');
		if (search.length < this.options.minLength) return;
		if (this.options.queryRemote){
			if (this.searchValues[search]){
				this.values = this.searchValues[search];
			} else {
				var data = this.options.remote.extraParams, that = this;
				if ($type(data) == 'function') data = data.run([], this);
				data[this.options.remote.param] = search;
				if (this.currentRequest) this.currentRequest.cancel();
				this.currentRequest = new Request.JSON({url: this.options.remote.url, data: data, onRequest: function(){
					that.showPlaceholder(that.options.remote.loadPlaceholder);
				}, onSuccess: function(data){
					that.searchValues[search] = data;
					that.values = data;
					that.showResults(search);
				}}).send();
			}
		} 
		if (this.values.length) this.showResults(search);
	},
	
	showResults: function(search){		
		var results = this.method.filter(this.values, search, this.options.insensitive, this.options.maxResults);
		if (this.index) results = results.filter(function(v){ return !this.index.contains(v); }, this);
		this.hidePlaceholder();
		if (!results.length) return;
		this.blur();
		this.list.empty().setStyle('display', 'block');
		results.each(function(r){ this.addResult(r, search); }, this);
		if (this.options.onlyFromValues) this.focusFirst();
		this.results = results;
	},	
	
	addResult: function(r, search){
		var element = new Element('li', {'class': this.prefix + '-result', 'html': $pick(r[3], r[1])}).store('textboxlist:auto:value', r);
		this.list.adopt(element);
		if (this.options.highlight) $$(this.options.highlightSelector ? element.getElements(this.options.highlightSelector) : element).each(function(el){
			if (el.get('html')) this.method.highlight(el, search, this.options.insensitive, this.prefix + '-highlight');
		}, this);
		if (this.options.mouseInteraction){
			element.setStyle('cursor', 'pointer').addEvents({
				mouseenter: function(){ this.focus(element); }.bind(this),
				mousedown: function(ev){
					ev.stop(); 
					$clear(this.hidetimer);
					this.doAdd = true;
				}.bind(this),
				mouseup: function(){
					if (this.doAdd){
						this.addCurrent();
						this.currentInput.focus();
						this.search();
						this.doAdd = false;
					}
				}.bind(this)
			});
			if (!this.options.onlyFromValues) element.addEvent('mouseleave', function(){ if (this.current == element) this.blur(); }.bind(this));	
		}
	},
	
	hide: function(ev){
		this.hidetimer = (function(){
			this.hidePlaceholder();
			this.list.setStyle('display', 'none');
			this.currentSearch = null;
		}).delay(Browser.Engine.trident ? 150 : 0, this);
	},
	
	showPlaceholder: function(customHTML){
		if (this.placeholder){
			this.placeholder.setStyle('display', 'block');	
			if (customHTML) this.placeholder.set('html', customHTML);
		}		
	},
	
	hidePlaceholder: function(){
		if (this.placeholder) this.placeholder.setStyle('display', 'none');
	},
	
	focus: function(element){
		if (!element) return this;
		this.blur();
		this.current = element.addClass(this.prefix + '-result-focus');
	},
	
	blur: function(){
		if (this.current){
			this.current.removeClass(this.prefix + '-result-focus');
			this.current = null;
		}
	},
	
	focusFirst: function(){
		return this.focus(this.list.getFirst());
	},
	
	focusRelative: function(dir){
		if (!this.current) return this;
		return this.focus(this.current['get' + dir.capitalize()]());
	},
	
	addCurrent: function(){
		var value = this.current.retrieve('textboxlist:auto:value');
		var b = this.textboxlist.create('box', value.slice(0, 3));
		if (b){
			b.autoValue = value;
			if (this.index != null) this.index.push(value);
			this.currentInput.setValue([null, '', null]);
			b.inject($(this.currentInput), 'before');
		}
		this.blur();
		return this;
	},
	
	navigate: function(ev){
		switch (ev.code){
			case Event.Keys.up:			
				ev.stop();
				(!this.options.onlyFromValues && this.current && this.current == this.list.getFirst()) ? this.blur() : this.focusRelative('previous');
				break;
			case Event.Keys.down:			
				ev.stop();
				this.current ? this.focusRelative('next') : this.focusFirst();
				break;
			case Event.Keys.enter:
				ev.stop();
				if (this.current) this.addCurrent();
				else if (!this.options.onlyFromValues){
					var value = this.currentInput.getValue();				
					var b = this.textboxlist.create('box', value);
					if (b){
						b.inject($(this.currentInput), 'before');
						this.currentInput.setValue([null, '', null]);
					}
				}
		}
	}
	
});

TextboxList.Autocomplete.Methods = {
	
	standard: {
		filter: function(values, search, insensitive, max){
			var newvals = [], regexp = new RegExp('\\b' + search.escapeRegExp(), insensitive ? 'i' : '');
			for (var i = 0; i < values.length; i++){
				if (newvals.length === max) break;
				if (values[i][1].test(regexp)) newvals.push(values[i]);
			}
			return newvals;
		},
		
		highlight: function(element, search, insensitive, klass){
			var regex = new RegExp('(<[^>]*>)|(\\b'+ search.escapeRegExp() +')', insensitive ? 'ig' : 'g');
			return element.set('html', element.get('html').replace(regex, function(a, b, c){
				return (a.charAt(0) == '<') ? a : '<strong class="'+ klass +'">' + c + '</strong>'; 
			}));
		}
	}
	
};

})();


/*
Script: TextboxList.Autocomplete.Binary.js
	TextboxList Autocomplete binary search extension

	Authors:
		Guillermo Rauch
	
	Note:
		TextboxList is not priceless for commercial use. See <http://devthought.com/projects/mootools/textboxlist/>
		Purchase to remove this message.
*/

TextboxList.Autocomplete.Methods.binary = {
	filter: function(values, search, insensitive, max){
		var method = insensitive ? 'toLowerCase' : 'toString', low = 0, high = values.length - 1, lastTry;
		search = search[method]();
		while (high >= low){
			var mid = parseInt((low + high) / 2);
			var curr = values[mid][1].substr(0, search.length)[method]();			
			var result = ((search == curr) ? 0 : ((search > curr) ? 1 : -1));
			if (result < 0) { high = mid - 1; continue; }
			if (result > 0) { low = mid + 1; continue; }
			if (result === 0) break;
		}		
		if (high < low) return [];
		var newvalues = [values[mid]], checkNext = true, checkPrev = true, v1, v2;
		for (var i = 1; i <= values.length - mid; i++){			
			if (newvalues.length === max) break;
			if (checkNext) v1 = values[mid + i] ? values[mid + i][1].substr(0, search.length)[method]() : false;
			if (checkPrev) v2 = values[mid - i] ? values[mid - i][1].substr(0, search.length)[method]() : false;
			checkNext = checkPrev = false;
			if (v1 === search) { newvalues.push(values[mid + i]); checkNext = true; }
			if (v2 === search) { newvalues.unshift(values[mid - i]); checkPrev = true; }
			if (! (checkNext || checkPrev)) break;
		}
		return newvalues;
	},
	
	highlight: function(element, search, insensitive, klass){
		var regex = new RegExp('(<[^>]*>)|(\\b'+ search.escapeRegExp() +')', insensitive ? 'ig' : 'g');
		return element.set('html', element.get('html').replace(regex, function(a, b, c, d){
			return (a.charAt(0) == '<') ? a : '<strong class="'+ klass +'">' + c + '</strong>'; 
		}));
	}
};


/*
Script: GrowingInput.js
	Alters the size of an input depending on its content

	License:
		MIT-style license.

	Authors:
		Guillermo Rauch
*/

(function(){

GrowingInput = new Class({
	
	Implements: [Options, Events],
	
	options: {
		min: 0,
		max: null,
		startWidth: 2,
		correction: 15
	},
	
	initialize: function(element, options){
		this.setOptions(options);
		this.element = $(element).store('growing', this).set('autocomplete', 'off');		                                                            		                                                           		
		this.calc = new Element('span', {
			'styles': {
				'float': 'left',
				'display': 'inline-block',
				'position': 'absolute',
				'left': -1000
			}
		}).inject(this.element, 'after');					
		['font-size', 'font-family', 'padding-left', 'padding-top', 'padding-bottom', 
		 'padding-right', 'border-left', 'border-right', 'border-top', 'border-bottom', 
		 'word-spacing', 'letter-spacing', 'text-indent', 'text-transform'].each(function(p){
				this.calc.setStyle(p, this.element.getStyle(p));
		}, this);				
		this.resize();
		var resize = this.resize.bind(this);
		this.element.addEvents({blur: resize, keyup: resize, keydown: resize, keypress: resize});
	},
	
	calculate: function(chars){
		this.calc.set('html', chars);
		var width = this.calc.getStyle('width').toInt();
		return (width ? width : this.options.startWidth) + this.options.correction;
	},
	
	resize: function(){
		this.lastvalue = this.value;
		this.value = this.element.value;
		var value = this.value;		
		if($chk(this.options.min) && this.value.length < this.options.min){
			if($chk(this.lastvalue) && (this.lastvalue.length <= this.options.min)) return;
			value = str_pad(this.value, this.options.min, '-');
		} else if($chk(this.options.max) && this.value.length > this.options.max){
			if($chk(this.lastvalue) && (this.lastvalue.length >= this.options.max)) return;
			value = this.value.substr(0, this.options.max);
		}
		this.element.setStyle('width', this.calculate(value));
		return this;
	}
	
});

var str_repeat = function(str, times){ return new Array(times + 1).join(str); };
var str_pad = function(self, length, str, dir){
	if (self.length >= length) return this;
	str = str || ' ';
	var pad = str_repeat(str, length - self.length).substr(0, length - self.length);
	if (!dir || dir == 'right') return self + pad;
	if (dir == 'left') return pad + self;
	return pad.substr(0, (pad.length / 2).floor()) + self + pad.substr(0, (pad.length / 2).ceil());
};

})();
