LeafletWidget.methods.imagePopup = function(image, group) {


  var lay = this.layerManager._groupContainers[group];

  var img = [];
  for (i = 0; i < image.length; i++) {
    var id = i + 1;
    id = id.toString();
    img[i] = document.getElementById("image" + "-" + id + "-attachment").href;
  }

  //debugger;

  lay.bindPopup("<image src='" + img + "'>", { maxWidth: 2000 });

};
