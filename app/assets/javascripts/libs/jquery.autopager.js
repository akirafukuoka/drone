/*
 * jQuery.autopager v1.0.0
 *
 * Copyright (c) 2009 lagos
 * Dual licensed under the MIT and GPL licenses.
 *
 * http://lagoscript.org
 */
(function(g){var i=this,n={},j,l,m,d=false,f={autoLoad:true,page:1,content:".content",link:"a[rel=next]",insertBefore:null,appendTo:null,start:function(){},load:function(){},disabled:false};g.autopager=function(o){var s=this.autopager;if(typeof o==="string"&&g.isFunction(s[o])){var q=Array.prototype.slice.call(arguments,1),r=s[o].apply(s,q);return r===s||r===undefined?this:r}o=g.extend({},f,o);s.option(o);j=g(o.content).filter(":last");if(j.length){if(!o.insertBefore&&!o.appendTo){var p=j.next();if(p.length){k("insertBefore",p)}else{k("appendTo",j.parent())}}}e();return this};g.extend(g.autopager,{option:function(p,q){var o=p;if(typeof p==="string"){if(q===undefined){return n[p]}o={};o[p]=q}g.each(o,function(r,s){k(r,s)});return this},enable:function(){k("disabled",false);return this},disable:function(){k("disabled",true);return this},destroy:function(){this.autoLoad(false);n={};j=l=m=undefined;return this},autoLoad:function(o){return this.option("autoLoad",o)},load:function(){if(d||!m||n.disabled){return}d=true;n.start(c(),h());g.get(m,a);return this}});function k(o,p){switch(o){case"autoLoad":if(p&&!n.autoLoad){g(i).scroll(b)}else{if(!p&&n.autoLoad){g(i).unbind("scroll",b)}}break;case"insertBefore":if(p){n.appendTo=null}break;case"appendTo":if(p){n.insertBefore=null}break}n[o]=p}function e(o){l=m||i.location.href;m=g(n.link,o).attr("href")}function b(){if(j.offset().top+j.height()<g(document).scrollTop()+g(i).height()){g.autopager.load()}}function a(q){var o=n,p=g("<div/>").append(q.replace(/<script(.|\s)*?\/script>/g,"")),r=p.find(o.content);k("page",o.page+1);e(p);
  if(r.length){
    if(o.insertBefore){
      r.insertBefore(o.insertBefore)
    }else{
      r.appendTo(o.appendTo)
    }
    o.load.call(r.get(),c(),h());
    j=r.filter(":last")
  }else{o.load.call(r.get(),c(),h());}d=false}function c(){return{page:n.page,url:l}}function h(){return{page:n.page+1,url:m}}})(jQuery);