(function($) {

	$.fn.preloader = function(opts) {
		var el;
		this.each(function() {
			var $this = $(this);
			el = $this.data('preloader');
			if (el && opts !== false) {
				clearInterval(el.data('interval'));
				el.remove();
				$this.removeData('preloader');
			}
			if (opts !== false) {
				opts = $.extend({color: $this.css('color')}, $.fn.preloader.defaults, opts);

				el = render($this, opts).css('position', 'absolute').prependTo(opts.outside ? 'body' : $this);
				var h = $this.outerHeight() - el.height();
				var w = $this.outerWidth() - el.width();
				var margin = {
					top: opts.valign == 'top' ? opts.padding : opts.valign == 'bottom' ? h - opts.padding : Math.floor(h / 2),
					left: opts.align == 'left' ? opts.padding : opts.align == 'right' ? w - opts.padding : Math.floor(w / 2)
				};
				var offset = $this.offset();
				if (opts.outside) {
					el.css({top: offset.top + 'px', left: offset.left + 'px'});
				}
				else {
					margin.top -= el.offset().top - offset.top;
					margin.left -= el.offset().left - offset.left;
				}
				//el.css({marginTop: margin.top + 'px', marginLeft: margin.left + 'px'});
				//el.css({marginTop: '50%', marginLeft: '50%'});
				//el.css({'left': '50%', 'top': '50%'});
				el.css({'left': '50%', 'top': '50%'});
				animate(el, opts);
				$this.data('preloader', el);
			}else{
				remove(el);
				$this.removeData('preloader');
			}
		});
		return el;
	};

	$.fn.preloader.defaults = {
		r: 12,
		border: 1,
		color: "#000000",
		speed: 1.2,
		padding: 4
	};

	var render = function() {
		return $('<div>').addClass('busy');
	};

	var animate = function() {
	};

	var num = 0;
	var timer;
	var countReset = function(){
		num = 0;
	}
	var countUp = function(){
		num += 1;
	}
	var count = function(){
		return num;
	};
	var remove = function(){
	};

	/**
	 * Utility function to create elements in the SVG namespace.
	 */
	function svg(tag, attr) {
		var el = document.createElementNS("http://www.w3.org/2000/svg", tag || 'svg');
		if (attr) {
			$.each(attr, function(k, v) {
				el.setAttributeNS(null, k, v);
			});
		}
		return $(el);
	}

	if (document.createElementNS && document.createElementNS( "http://www.w3.org/2000/svg", "svg").createSVGRect) {

		render = function(target, d) {
			var innerRadius = d.width*2 + d.space;
			var r = d.r;

			var el = svg().width(r*4).height(r*4).css({"margin-left":"-"+(r*2)+"px","margin-top":"-"+(r*2)+"px"});
			var c = svg('circle', {
				'r':r,
				'cx':r*2,
				'cy':r*2,
				'stroke-width': d.border,
				'stroke': d.color,
				'fill': 'none'
			}).appendTo(el);
			var path = svg('path', {
				'd':'M0,0 a0,0 0 0,1 0,0 L0,0 Z',
				'fill':d.color
			}).appendTo(el);

			el.stop();
			//el.css({"opacity":0});
			//el.animate({"opacity":1},100);

			return $('<div>').append(el).width(0).height(0);
		};


		var animations = {};
		var animated = false;

		animate = function(el, d) {
			/*
			clearInterval(timer);
			timer = setInterval(
				draw(el, d);
			},20);
			*/
			draw(el,d);
				//requestAnimationFrame(function(){
					//draw(el,d)
				//});
		};
		draw = function(el, d){
			if(el != undefined){
				console.log("draw");
				var r = d.r;
				var maxCount = 100;

				countUp();
				if(count()>=maxCount){
					countReset();
				}

				///*
				var startR = Math.PI*(0);
				var endR = Math.PI*(0) + Math.PI*(2)*(count()/maxCount);
				if(count()<maxCount*0.5){
					startR = Math.PI*(0);
					endR = Math.PI*(0) + Math.PI*(2)*(count()/(maxCount*0.5));
				}else{
					startR = Math.PI*(0) + Math.PI*(2)*((count()-maxCount*0.5)/(maxCount*0.5));
					endR = Math.PI*(0) + Math.PI*(2)*1;
				}

				var cx = r*2;
				var cy = r*2;


				var ox = cx+r*Math.sin(startR);
				var oy = cy-r*Math.cos(startR);
				var ex = cx+r*Math.sin(endR) - ox;
				var ey = cy-r*Math.cos(endR) - oy;

				var sx = 0;
				if(ex<=0){
					sx = 1;
				}
				var sy = 1;

				if(count()==maxCount*0.5){
					el.find("circle").attr("fill",d.color);
				}else{
					el.find("circle").attr("fill","none");
				}

				el.find("path").attr("d","M"+ox+","+oy+" a"+r+","+r+" 0 "+sx+","+sy+" "+ex+","+ey+" L"+cx+","+cy+" Z");

				timer = requestAnimationFrame(function(){
					draw(el, d)
				});
			}
		}
		remove = function(el) {
			console.log("remove")
			if(timer)cancelAnimationFrame(timer);
			if(el != undefined){
				el.stop()
				//clearInterval(timer);

				el.remove();
			}
		}

	} else {

	}

})(jQuery);
