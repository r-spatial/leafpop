LeafletWidget.methods.imagePopup = function(image, group, width, height, src, name) {

  var lay = this.layerManager._groupContainers[group];

  //debugger;

  var img = [];
  for (i = 0; i < image.length; i++) {
    if (src[i] === "l") {
      if (name.length === 1) {
        img[i] = document.getElementById("image" + "-" + name + "-attachment").href;
      } else {
        img[i] = document.getElementById("image" + "-" + name[i] + "-attachment").href;
      }
    }
    if (src[i] === "r") {
      r_img = new Image();
      r_img.src = image[i];
      if (width[i] === null & height[i] === null) {
        width[i] = r_img.width;
        height[i] = r_img.height;
      } else if (width[i] === null) {
        xy_ratio = r_img.width / r_img.height;
        width[i] = xy_ratio * height[i];
      } else if (height[i] === null) {
        xy_ratio = r_img.height / r_img.width;
        height[i] = xy_ratio * width[i];
      }
      img[i] = image[i];
    }
  }

  //debugger;

  var imgid = 0;
  lay.eachLayer(function (layer) {
    wdth = width[imgid];
    hght = height[imgid];
    if (imgid <= image.length) {
      pop = "<image src='" + img[imgid] + "'" + " height=" + hght + " width=" + wdth + ">";
      layer.bindPopup(pop, { maxWidth: 2000 });
    }
    //debugger;
    imgid += 1;
  });

};


LeafletWidget.methods.videoPopup = function(video, group, width, height, name) {

  var lay = this.layerManager._groupContainers[group];

  //debugger;

  var vdo = [];
  var vid = [];

  for (i = 0; i < video.length; i++) {
    if (name.length === 1) {
      vdo[i] = document.getElementById("video" + "-" + name + "-attachment").href;
    } else {
      vdo[i] = document.getElementById("video" + "-" + name[i] + "-attachment").href;
    }

    vid[i] = document.createElement('video');
    vid[i].src = vdo[i];

    if (width[i] === null & height[i] === null) {
      width[i] = vid[i].videoWidth;
      height[i] = vid[i].videoHeight;
    } else if (width[i] === null) {
      xy_ratio = vid[i].videoWidth / vid[i].videoHeight;
      width[i] = xy_ratio * height[i];
    } else if (height[i] === null) {
      xy_ratio = vid[i].videoHeight / vid[i].videoWidth;
      height[i] = xy_ratio * width[i];
    }
  }

  //debugger;

  var vdoid = 0;
  lay.eachLayer(function (layer) {
    wdth = width[vdoid];
    hght = height[vdoid];
    if (vdoid <= video.length) {
      pop = "<video controls src='" + vid[vdoid].src + "'" + " height=" + hght + " width=" + wdth + ">";
      layer.bindPopup(pop, { maxWidth: 2000 });
    }
    //debugger;
    vdoid += 1;
  });

};




LeafletWidget.methods.iframePopup = function(source, group, width, height, src, name) {

  var lay = this.layerManager._groupContainers[group];

  //debugger;

  var frm = [];
  for (i = 0; i < source.length; i++) {
    if (src[i] === "l") {
      if (name.length === 1) {
        frm[i] = document.getElementById("iframe" + "-" + name + "-attachment").href;
      } else {
        frm[i] = document.getElementById("iframe" + "-" + name[i] + "-attachment").href;
      }
    }
    if (src[i] === "r") {
      frm[i] = source[i];
    }
  }

   //debugger;

  var srcid = 0;
  lay.eachLayer(function (layer) {
    wdth = width;
    hght = height;
    if (srcid <= source.length) {
      pop = "<iframe src='" +
        frm[srcid] +
        "' frameborder=0 width=" + wdth +
        " height=" + hght +
        "></iframe>";

      layer.bindPopup(pop, { maxWidth: 2000 });
    }
    //debugger;
    srcid += 1;
  });

};
