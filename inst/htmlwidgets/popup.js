LeafletWidget.methods.imagePopup = function(image, group) {

  var lay = this.layerManager._groupContainers[group];
  lay.bindPopup(image, { maxWidth: 2000 });

};
