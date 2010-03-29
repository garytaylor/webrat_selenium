var locationStrategies = selenium.browserbot.locationStrategies;
var locatorParts = locator.split('|');
var cssAncestor = locatorParts[0];
var fieldText = locatorParts[1];
var matchingElements = cssQuery(cssAncestor, inDocument);
var candidateElements = matchingElements.collect(function(ancestor){
    return locationStrategies['id'].call(this, locator, ancestor, inWindow)
            || locationStrategies['name'].call(this, locator, ancestor, inWindow)
            || locationStrategies['label'].call(this, locator, ancestor, inWindow)
            || null;

}).flatten().compact();
if (candidateElements.length == 0) {
  return null;
}
candidateElements = candidateElements.sortBy(function(s) { return s.length * -1; }); //reverse length sort
return candidateElements.first();


