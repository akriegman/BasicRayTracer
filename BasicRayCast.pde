float ds = 0.002;
float r = 2;
int aliasnum = 4; 

PVector camera = new PVector(-4,-1,0);
PVector look = new PVector(4,1,0);
PVector up = new PVector(0,1,0);
PVector sun = new PVector(0,4,4);
float viewAngle = PI/4;

PVector white = new PVector(255, 255, 255);

void setup()
{
  size(800, 600);
  noLoop();
  look.normalize();
  up.normalize();
  
}

void draw()
{
  for (int i=0; i<width; i++) //for each pixel
  {
    for (int j=0; j<height; j++)
    {
      //perturb foc by a small amount aliasnum ^ 2 times, then average the RGB values
      int r = 0, g = 0, b = 0;
      for (int k = 0; k < aliasnum * aliasnum; k++)
      {
        //get vector pointing from camera to pixel
        PVector focus = look.copy();
        focus.add(PVector.mult(up, tan(viewAngle) * (height / 2.0 - j - float(k % aliasnum) / aliasnum) / width * 2));
        focus.add(PVector.mult(look.cross(up).normalize(), tan(viewAngle) * (i + float(k / aliasnum) / aliasnum - width / 2.0) / width * 2));
        
        color c = rayCast(focus);
        r += c>>16&0xFF;
        g += c>>8&0xFF;
        b += c&0xFF;
      }
      r /= aliasnum * aliasnum;
      g /= aliasnum * aliasnum;
      b /= aliasnum * aliasnum;
      color aliased = color(r, g, b);
      
      //finally draw the pixel
      stroke(aliased);
      point(i, j);
    }
  }
  save("image" + (int)random(10000) + ".png");
}

color rayCast (PVector focus) //casts a ray, reflects light, returns a color
{
  PVector out = new PVector(248, 255, 248);
  boolean hit;
  
  //solve for intersection with sphere
  float lam;
  float a = camera.dot(camera) - r * r;
  float b = 2*camera.dot(focus);
  float c = focus.dot(focus);
  float d = b*b-4*a*c;
  if (d < 0) {
    hit = false;
    lam = (-r-camera.y)/focus.y;
  } else if (-b - sqrt(d) > 0) {
    hit = true;
    lam = (-b - sqrt(d))/2/a;
  } else if (-b + sqrt(d) > 0) {
    hit = true;
    lam = (-b + sqrt(d))/2/a;
  } else {
    hit = false;
    lam = (-r-camera.y)/focus.y;
  }
  
  //don't draw objects behind the camera
  if (lam < 0) {
    return color(255, 255, 255);
  }
  
  focus.mult(lam);
  PVector point = PVector.add(camera,focus); //point of impact of line of sight
  PVector lighting = PVector.sub(point, sun); //angle of lighting
  PVector normal;
  
  if (hit) {
    normal = point.copy(); //normal vector for sphere
  } else {
    normal = up; //normal vector for ground
  }
  
  focus.normalize();
  lighting.normalize();
  
  //brigthness is proportional to the cosine of the angle between the normal vector and
  //what would the normal vector would have to be to bounce light directly into the camera.
  //different functions of this angle could be used to simulate less or more reflective surfaces.
  float bright = abs(normal.dot(PVector.add(focus, lighting))/normal.mag()/PVector.add(focus, lighting).mag());
  
  //this part is just to make it look cool
  //int min = 30;
  //int max = 180;
  //note that the average of three uniform variables is exactly equal to a gaussian. (jk)
  //if ((random(min, max) +  random(min, max) +  random(min, max)) /3 < bright) {
  //  out = color(248, 255, 248);
  //} else {
  //  out = color(0, 10, 0);
  //}
  out.mult(bright);
  out.add(PVector.mult(white, pow(sin(bright * PI / 2), 20)));
  
  return color(out.x, out.y, out.z);
}
