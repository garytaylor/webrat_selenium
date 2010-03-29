var locatorParts = locator.split('|');
var cssAncestor = locatorParts[0];
var linkText = locatorParts[1];
var matchingElements = cssQuery(cssAncestor, inDocument);
var candidateLinks = matchingElements.collect(function(ancestor){
  var links = ancestor.getElementsByTagName('a');
  return $A(links).select(function(candidateLink) {
      var textMatched = false;
      var titleMatched = false;
      var idMatched = false;

      if (getText(candidateLink).toLowerCase().indexOf(locator.toLowerCase()) != -1) {
        textMatched = true;
      }

      if (candidateLink.title.toLowerCase().indexOf(locator.toLowerCase()) != -1) {
        titleMatched = true;
      }

      if (candidateLink.id.toLowerCase().indexOf(locator.toLowerCase()) != -1) {
        idMatched = true;
      }

      return textMatched || idMatched || titleMatched;
      
  });
}).flatten().compact();
if (candidateLinks.length == 0) {
  return null;
}
candidateLinks = candidateLinks.sortBy(function(s) { return s.length * -1; }); //reverse length sort
return candidateLinks.first();
