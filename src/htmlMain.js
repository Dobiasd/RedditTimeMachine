//source: http://stackoverflow.com/questions/11582512/how-to-get-url-parameters-with-javascript
function getURLParameter(name) {
  return decodeURIComponent((new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)').exec(location.search)||[,""])[1].replace(/\+/g, '%20'))||null
}
function getURLParameterDef(name, def) {
  var val = getURLParameter(name);
  if (val)
    return val;
  return def;
}
function GetTimezoneOffsetInMinutes() {
  var x = new Date();
  return x.getTimezoneOffset();
}
function Init() {
  lastQuery = ""
  var query = getURLParameterDef("query", "");
  var mainDiv = document.getElementById('main');
  page = Elm.embed(Elm.Main, mainDiv,
                   {query : query,
                    timezoneOffsetInMinutes : GetTimezoneOffsetInMinutes(),
                    useRegexInStr : getURLParameterDef("useregex", ""),
                    sfwInStr : getURLParameterDef("sfw", ""),
                    nsfwInStr : getURLParameterDef("nsfw", ""),
                    sortedByInStr : getURLParameterDef("sortedby", ""),
                    intervalInStr : getURLParameterDef("interval", ""),
                    amountInStr : getURLParameterDef("amount", ""),
                    pageInStr : getURLParameterDef("page", "")});

  page.ports.selected.subscribe(Selected);
  page.ports.showQuery.subscribe(ShowQuery);
  page.ports.staticLinkOut.subscribe(SetUrl);
  page.ports.queryColor.subscribe(SetQueryColor);

  // Send page to trigger signal in Elm.
  page.ports.pageInStr.send(getURLParameterDef("page", ""));

  var queryElem = document.getElementById("queryField");
  queryElem.value = query;
  queryElem.focus();
  queryElem.select();

  setInterval(CheckQuery, 100);
}
function SetUrl(url) {
  history.replaceState({}, "Reddit Time Machine", url);
}
function CheckQuery() {
  var queryElem = document.getElementById("queryField");
  if (!queryElem)
    return;
  var query = queryElem.value;
  if (query != lastQuery) {
    lastQuery = query;
    page.ports.timezoneOffsetInMinutes.send(GetTimezoneOffsetInMinutes());
    page.ports.query.send(query);
    SetTitle(query);
  }
}
function Selected(name) {
  document.getElementById("queryField").value = name;
  SetTitle(name);
}
function ShowQuery(on) {
  var queryElem = document.getElementById("queryField");
  if (on) {
    queryElem.style.visibility='visible';
    queryElem.focus();
  } else {
    queryElem.style.visibility='hidden';
  }
}
function SetQueryColor(col) {
  var queryElem = document.getElementById("queryField");
  if (!queryElem)
    return;
  queryElem.style.backgroundColor = col;
}
function SetTitle(name) {
  var subreddit = "reddit";
  if (name) {
    subreddit = "/r/" + name;
  }
  var title = "Reddit Time Machine - check out what was up on " + subreddit + " days/weeks/months ago";
  document.title = title;
}