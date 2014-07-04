//source: http://stackoverflow.com/questions/11582512/how-to-get-url-parameters-with-javascript
function getURLParameter(name) {
  return decodeURIComponent((new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)').exec(location.search)||[,""])[1].replace(/\+/g, '%20'))||null
}
function getURLParameterDef(name, def) {
  val = getURLParameter(name);
  if (val)
    return val;
  return def;
}
function GetTimezoneOffsetInMinutes() {
  var x = new Date();
  return x.getTimezoneOffset();
}
function Init() {
  lastQuery = getURLParameterDef("query", "");
  var mainDiv = document.getElementById('main');
  page = Elm.embed(Elm.Main, mainDiv,
                   {query : lastQuery,
                    timezoneOffsetInMinutes : GetTimezoneOffsetInMinutes(),
                    useRegexInStr : getURLParameterDef("useregex", ""),
                    sfwInStr : getURLParameterDef("sfw", ""),
                    nsfwInStr : getURLParameterDef("nsfw", ""),
                    sortedByInStr : getURLParameterDef("sortedby", ""),
                    intervalInStr : getURLParameterDef("interval", ""),
                    amountInStr : getURLParameterDef("amount", "")});

  ShowQuery(true);
  page.ports.selected.subscribe(Selected);
  page.ports.showQuery.subscribe(ShowQuery);
  page.ports.staticLinkOut.subscribe(SetUrl);
  page.ports.isQuerySurelyFound.subscribe(FoundQuery);

  setInterval(CheckQuery, 100);
}
function SetUrl(url) {
  history.replaceState({}, "Reddit Time Machine", url);
}
function CheckQuery() {
  queryElem = document.getElementById("queryField");
  if (!queryElem)
    return;
  query = queryElem.value;
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
  if (on) {
    if (document.getElementById("queryField"))
      return;
    var input = document.createElement("input");
    input.type = "text";
    var queryDiv = document.getElementById('query');
    input.placeholder = "enter subreddit"
    input.id = "queryField";
    queryDiv.appendChild(input);
    if (lastQuery)
      input.value = lastQuery;
    input.focus();
    input.select();
  }
  else
  {
    elem = document.getElementById("queryField");
    if (!elem)
      return;
    elem.remove();
  }
}
function FoundQuery(val) {
  var queryElem = document.getElementById("queryField");
  if (val) {
    queryElem.style.backgroundColor = "PaleGreen";
  } else {
    queryElem.style.backgroundColor = "LightYellow";
  }
}
function SetTitle(name) {
  subreddit = "reddit";
  if (name) {
    subreddit = "/r/" + name;
  }
  title = "Reddit Time Machine - check out what was up on + " + subreddit + " days/weeks/months ago";
  document.title = title;
}