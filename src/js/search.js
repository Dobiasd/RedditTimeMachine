sfwOn = true;
nsfwOn = false;
subreddits = [];
query = "";
isCalculating = false;
page = undefined;

function InitSearch(newQuery) {
  query = newQuery;
  StartSearch();
}
function StartSearch() {
  isCalculating = false;
  console.log("go");
  setTimeout(Search, 1);
}
function BuildSubreddits() {
  subreddits = [];
  if (sfwOn) subreddits = subreddits.concat(sfw);
  if (nsfwOn) subreddits = subreddits.concat(nsfw);
}
function SfwOn(val) {
  sfwOn = val;
  BuildSubreddits();
  StartSearch();
}
function NsfwOn(val) {
  nsfwOn = val;
  BuildSubreddits();
  StartSearch();
}
function ParseSubreddits(raw) {
  return raw.map(
    function(r) {
      splitted = r.split(",");
      var name = splitted[0];
      var count = splitted[1];
      return [name, parseInt(count)];
    });
}
function Search() {
  var isCalculating = true;
  allStarting = [];
  var arrayLength = subreddits.length;
  for (var i = 0; i < arrayLength; ++i) {
    sr = subreddits[i];
    srName = sr[0];
    if (StartsWith(srName, query))
      allStarting.push(sr);
    if (!isCalculating)
    {
      console.log("break1");
      return;
    }
  }
  maxSuggestions = 10 + 1; // one more as in elm code for "..."
  allStarting = allStarting.sort(CmpBySndInverse);
  result = allStarting.map(Fst);
  if (result.length < maxSuggestions)
  {
    allContaining = [];
    for (var i = 0; i < arrayLength; ++i) {
      sr = subreddits[i];
      srName = sr[0]
      if (ContainsAndNotStarts(srName, query))
        allContaining.push(sr);
      if (!isCalculating)
      {
        console.log("break2");
        return;
      }
    }
    allContaining = allContaining.sort(CmpBySndInverse);
    result = result.concat(allContaining.map(Fst));
  }

  result = result.slice(0, maxSuggestions);
  page.ports.suggestionList.send(result.join());
}
function CmpBySndInverse(a, b) {
  return Snd(b) - Snd(a);
}
function StartsWith(a, b) {
  return a.slice(0, b.length) == b;
}
function Contains(a, b) {
  return a.indexOf(b) > -1;
}
function ContainsAndNotStarts(a, b) {
  return !StartsWith(a, b) && Contains(a, b);
}
function Fst(x) {
  return x[0]
}
function Snd(x) {
  return x[1]
}