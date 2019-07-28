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
  //var vid = [];
  //var wdth = [];
  //var hght = [];
  var vdoid = 0;

  lay.eachLayer(function (layer) {

    if (name.length === 1) {
      vdo[vdoid] = document.getElementById("video" + "-" + name + "-attachment").href;
    } else {
      vdo[vdoid] = document.getElementById("video" + "-" + name[vdoid] + "-attachment").href;
    }

    //vid[vdoid] = document.createElement('video');
    var vid = document.createElement('video');
    var id = 'leafpop-video' + vdoid;
    vid.setAttribute('id', id);
    vid.src = vdo[vdoid];
    vid.controls = true;
/*
    if (width[vdoid] === null & height[vdoid] === null) {
      wdth = vid[vdoid].videoWidth;
      hght = vid[vdoid].videoHeight;
    } else if (width[vdoid] === null) {
      xy_ratio = vid[vdoid].videoWidth / vid[vdoid].videoHeight;
      wdth = xy_ratio * height[vdoid];
      hght = height[vdoid];
    } else if (height[vdoid] === null) {
      xy_ratio = vid[vdoid].videoHeight / vid[vdoid]  .videoWidth;
      hght = xy_ratio * width[vdoid];
      wdth = width[vdoid];
    }
*/

    var wdth;
    var hght;
    var xy_ratio = vid.videoWidth / vid.videoHeight;
    var yx_ratio = vid.videoHeight / vid.videoWidth;

    debugger;

    if (width[vdoid] !== null) {
      wdth = width[vdoid];
      hght = vid.videoWidth * yx_ratio;
    } else if (height[vdoid] !== null ) {
      hght = height[vdoid];
      wdth = vid.videoHeight * xy_ratio;
    } else {
      wdth = vid.videoWidth;
      hght = vid.videoHeight;
    }

    vid.setAttribute('width', wdth);
    vid.setAttribute('height', hght);

    if (vdoid <= video.length - 1) {
      //pop = "<video controls src='" + vdo[vdoid] + "'" + " height=" + height[vdoid] + " width=" + width[vdoid] + ">";
      layer.bindPopup(vid, { width: wdth, height: hght, maxWidth: 2000 });
      vdoid += 1;
    }
    //debugger;
    //if (vdoid < name.length) { vdoid += 1 }
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
