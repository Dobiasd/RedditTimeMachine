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
function Init() {
  lastQuery = getURLParameterDef("subreddit", "");
  var mainDiv = document.getElementById('main');
  page = Elm.embed(Elm.RedditTimeMachine, mainDiv,
                   {query:lastQuery,
                    sfwInStr:getURLParameterDef("sfw", ""),
                    nsfwInStr:getURLParameterDef("nsfw", ""),
                    sortedByInStr:getURLParameterDef("sortedby", ""),
                    intervalInStr:getURLParameterDef("interval", ""),
                    amountInStr:getURLParameterDef("amount", ""),});

  ShowQuery(true);
  page.ports.selected.subscribe(Selected);
  page.ports.showQuery.subscribe(ShowQuery);
  setInterval(CheckQuery, 100);
}
function CheckQuery() {
  queryElem = document.getElementById("queryField");
  if (!queryElem)
    return;
  query = queryElem.value;
  if (query != lastQuery) {
    lastQuery = query;
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
  }
  else
  {
    elem = document.getElementById("queryField");
    if (!elem)
      return;
    elem.remove();
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