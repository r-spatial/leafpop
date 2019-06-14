LeafletWidget.methods.imagePopup = function(image, group, width, height) {


  var lay = this.layerManager._groupContainers[group];

//  debugger;

  var img = [];
  for (i = 0; i < image.length; i++) {
    var id = i + 1;
    id = id.toString();
    img[i] = document.getElementById("image" + "-" + id + "-attachment").href;
  }

  //debugger;

  var imgid = 0;
  lay.eachLayer(function (layer) {
    wdth = width[imgid];
    hght = height[imgid];
    pop = "<image src='" + img[imgid] + "'" + " height=" + hght + " width=" + wdth + ">";
    layer.bindPopup(pop, { maxWidth: 2000 });
    //debugger;
    imgid += 1;
  });

};
