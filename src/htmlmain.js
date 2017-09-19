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

function AcceptCookies() {
  if (lsTest() === true) {
    try {
      localStorage.setItem("cookieConsent", "true");
    } catch(e) {
    }
  }
  CheckCookieConsent();
}

function HideCookieRemark()
{
  document.getElementById('cookieRemark').style.height ='0px';
  document.getElementById('cookieRemark').style.padding ='0px';
  document.getElementById('cookieRemark').style.visibility = 'hidden';
  document.getElementById('ads').style.top = '0px';
}

function ShowCookieRemark()
{
  document.getElementById('cookieRemark').style.height ='18px';
  document.getElementById('cookieRemark').style.padding ='10px';
  document.getElementById('cookieRemark').style.visibility = 'visible';
  document.getElementById('ads').style.top = '38px';
}

// http://stackoverflow.com/questions/16427636/check-if-localstorage-is-available
function lsTest(){
  var test = 'test';
  try {
    localStorage.setItem(test, test);
    localStorage.removeItem(test);
    return true;
  } catch(e) {
    return false;
  }
}

function CheckCookieConsent() {
  if (lsTest() === true) {
    try {
      cookieConsent = localStorage.getItem("cookieConsent");
      if (cookieConsent == "true"){
        HideCookieRemark();
        document.getElementById("queryField").style.top = "240px";
        document.getElementById("searchField").style.top = "492px";
      }
      else
      {
        ShowCookieRemark();
        document.getElementById("queryField").style.top = "278px";
        document.getElementById("searchField").style.top = "530px";
      }
    } catch(e) {
      return "";
    }
  }
}

function Init() {
  CheckCookieConsent();
  lastQuery = ""
  lastSearch = ""
  var query = getURLParameterDef("query", "");
  var search = getURLParameterDef("search", "");
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
                    pageInStr : getURLParameterDef("page", ""),
                    searchTypeInStr : getURLParameterDef("searchtype", ""),
                    search : search});

  page.ports.selected.subscribe(Selected);
  page.ports.showQueryAndSearch.subscribe(ShowQueryAndSearch);
  page.ports.staticLinkOut.subscribe(SetUrl);
  page.ports.queryColor.subscribe(SetQueryColor);

  // Send page to trigger signal in Elm.
  page.ports.pageInStr.send(getURLParameterDef("page", ""));

  var queryElem = document.getElementById("queryField");
  queryElem.value = query;
  queryElem.focus();
  queryElem.select();
  setInterval(CheckQuery, 100);

  var searchElem = document.getElementById("searchField");
  searchElem.value = search;
  setInterval(CheckSearch, 123);
}
function SetUrl(url) {
  history.replaceState({}, "Reddit Time Machine", url);
}
function CheckQuery() {
  var queryElem = document.getElementById("queryField");
  if (!queryElem)
    return;
  var query = queryElem.value;

  // Produce a temporary regex object
  // to let the exeption be thrown here
  // instead of inside elm.
  // https://groups.google.com/forum/?fromgroups#!topic/elm-discuss/7Uwl5-usqjs
  var re = new RegExp(query);
  if (query != lastQuery) {
    lastQuery = query;
    page.ports.query.send(query);
    SetTitle(query);
  }
}
function CheckSearch() {
  var searchElem = document.getElementById("searchField");
  if (!searchElem)
    return;
  var search = searchElem.value;
  if (search != lastSearch) {
    lastSearch = search;
    page.ports.search.send(search);
  }
}
function Selected(name) {
  document.getElementById("queryField").value = name;
  SetTitle(name);
}
function ShowQueryAndSearch(on) {
  var queryElem = document.getElementById("queryField");
  var searchElem = document.getElementById("searchField");
  if (on) {
    searchElem.style.visibility='visible';
    queryElem.style.visibility='visible';
    queryElem.focus();
    queryElem.select();
  } else {
    queryElem.style.visibility='hidden';
    searchElem.style.visibility='hidden';
  }
}
function SetQueryColor(col) {
  var queryElem = document.getElementById("queryField");
  if (!queryElem)
    return;
  queryElem.style.backgroundColor = col;
}
function SetTitle(name) {
  var subreddit = "";
  if (name) {
    subreddit = " - /r/" + name;
  }
  var title = "Reddit Time Machine" + subreddit;
  document.title = title;
}