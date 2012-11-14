// Generated by CoffeeScript 1.3.3
var ChinstrapRenderer;

ChinstrapRenderer = (function() {

  function ChinstrapRenderer() {}

  ChinstrapRenderer.prototype.debug = false;

  ChinstrapRenderer.prototype.templatePool = function() {
    return {};
  };

  ChinstrapRenderer.prototype.merge = function(str, data, subtemplates) {
    var res;
    if (subtemplates == null) {
      subtemplates = {};
    }
    str = this.templatePool[str] || str;
    if (typeof str === "function") {
      this.fn = str;
    } else {
      res = this.render(str, subtemplates);
      this.fn = new Function("obj", res);
    }
    return this.fn(data);
  };

  ChinstrapRenderer.prototype.render = function(str, subtemplates) {
    if (subtemplates == null) {
      subtemplates = {};
    }
    str = str.replace(/[\r\t\n]/g, " ");
    str = str.split("{{").join("\t");
    str = str.replace(/((^|\}\})[^\t]*)'/g, "$1\r");
    str = str.replace(/\t\s?=(.*?)\}\}/g, "',value($1),'");
    str = str.replace(/\t\s?\#(.*?)\}\}/g, "");
    str = str.replace(/\t\s?\@\=(.*?)\}\}/g, "\t iterator=$1; }}");
    str = str.replace(/\t\s?WHILE(.*?)\}\}/g, "\t while ($1) { }}");
    str = str.replace(/\t\s?\/WHILE(.*?)\}\}/g, "\t } }}");
    str = str.replace(/\t\s?FOR(.*?)\}\}/g, "\t for ($1) { }}");
    str = str.replace(/\t\s?\/FOR(.*?)\}\}/g, "\t } }}");
    str = str.replace(/\t\s?%(.*?)\}\}/g, "', this.merge($1), '");
    str = str.replace(/\t\s?(IF|\?)(.*?)\}\}/g, "\t if (value($2)) { }}");
    str = str.replace(/\t\s?\/(IF|\?)(.*?)\}\}/g, "\t } }}");
    str = str.replace(/\t\s?(\-\?|ELSEIF)(.*?)\}\}/g, "\t } else if (value($2)) { }}");
    str = str.replace(/\t\s?(\-|ELSE)(.*?)\}\}/g, "\t } else { }}");
    str = str.replace(/\@\@/g, "iterator");
    str = str.replace(/\@/g, "iterator.");
    str = str.split("\t").join("');");
    str = str.split("}}").join("p.push('");
    str = str.split("\r").join("\\'");
    str = "var p=[],iterator = {},print=function(){p.push.apply(p,arguments);}," + "sub=function(name){ return subtemplates[name]},value = function(val){ if (typeof val == 'function') { return val.apply(iterator); } else {return val;} };" + "with(obj){p.push('" + str + "');} return p.join('');";
    if (this.debug) {
      str = str.replace(/(\;|\{|\})/g, '$1\n');
      console.log("Return: ", str);
    }
    return str;
  };

  return ChinstrapRenderer;

})();