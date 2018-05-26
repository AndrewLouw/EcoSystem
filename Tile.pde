class Tile {
  String type;
  float Vegetation;
  float Max_Vegetation;
  float Meat;
  float Nutrients;
  int x;
  int y;
  float tilesize;
  ArrayList<Animal> current_animals = new ArrayList<Animal>();
  int kill;

  Tile(String create, float size, int i, int j) {
    tilesize = size;
    x=i;
    y=j;
    type = create;
    switch(type) {
    case "grass":
      Max_Vegetation=1;
      break;
    case "stone":
      Max_Vegetation=0.2;
      break;
    case "water":
      Max_Vegetation=0.5;
      break;
    default:
      Max_Vegetation=0;
      break;
    }
    Max_Vegetation = Max_Vegetation*2;
    Vegetation=Max_Vegetation*0.1;
    Nutrients = 4*noise(x, y);
    Meat = 0;
  }

  void Grow() {
    float temp;
    if (Meat<=0) {
      float modifier;
      switch(type) {
      case "grass":
        modifier=0.002;
        break;
      case "stone":
        modifier=0.0002;
        break;
      case "water":
        modifier=0.006;
        break;
      default:
        modifier=0;
        break;
      }

      temp = Max_Vegetation*modifier/(1+exp(-(Nutrients-1)*4));
      Nutrients = max(Nutrients - min(temp, Max_Vegetation-Vegetation)*0.005, 0);
      Vegetation = min(Vegetation +temp, Max_Vegetation);
    } else {

      temp=Meat*0.02+0.01;
      Nutrients = Nutrients +min(Meat, temp);
      Meat = max(Meat-temp, 0);
    }
  }

  int find_animal(int id) {
    for (int i=0; i<current_animals.size(); i++) {
      if (current_animals.get(i).unique_id == id) {
        return i;
      }
    }
    return -1;
  }

  void Show() {
    if (kill<0){
      switch(type) {
      case "grass":
        fill(10+Meat*100, 100+50*Vegetation/Max_Vegetation, 10);
        //fill(1000000*Meat, 0, 0);
        break;
      case "stone":
        fill(100+Meat*100, 100+25*Vegetation/Max_Vegetation, 100);
        break;
      case "water":
        fill(50*Vegetation/Max_Vegetation+Meat*100, 20+50*Vegetation/Max_Vegetation, 200);
        break;
      default:
        fill(0, 0, 0);
      }
    }else{
      fill(255, 0, 0);
      kill--;
    }
    rect(tilesize*(x), tilesize*(y), tilesize, tilesize);
  }
}
