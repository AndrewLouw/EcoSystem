class Animal {
  //Mutable
  int unique_id;
  int species;

  float Attack;
  float Defence;
  float Defence_attack;

  float Water_speed;
  float Land_speed;

  float conversion;

  float adult_mass;

  float decision_fraction;
  NeuralNet animal_analysis;
  NeuralNet tile_analysis;
  NeuralNet decide;

  //Variables
  Tile current_tile; 
  float stomach_size;
  float max_health;
  float max_fat;
  float max_muscle;

  float mass;
  float total_mass;

  float food;
  float water;

  float fat;
  float muscle;

  float health;
  float age;

  float tilesize;
  float x;
  float y;
  float dir;
  float seed;
  int bias;

  boolean split;
  boolean die;

  float[] stats = new float[10];

  Animal(String init, float size, Animal parent, int id) {
    unique_id=id;
    tilesize = size;
    age = 0;
    dir = random(0, TWO_PI);
    seed = random(0, 100);
    bias = floor(random(0, 8));
    split = false;
    die = false;

    if (init == "random") { 
      species = unique_id*10000+floor(random(0,10000));
      float temp;


      Attack = random(0, 1);
      Defence = random(0, 1);
      Defence_attack=random(0, 1);
      temp = Attack+Defence+Defence_attack;
      Attack = Attack/temp;
      Defence=Defence/temp;
      Defence_attack=Defence_attack/temp;

      Water_speed = random(0, 1);
      Land_speed = random(0, 1);
      temp = Water_speed+Land_speed;
      Water_speed = Water_speed/temp;
      Land_speed=Land_speed/temp;

      conversion = random(0, 1);

      adult_mass = random(0.5, 2);
      max_health = adult_mass;
      health = max_health/2;

      mass = adult_mass/2;
      stomach_size = adult_mass/3;
      max_muscle=adult_mass;
      max_fat=adult_mass;


      food = 0.5*stomach_size;
      water = 0.5;
      muscle =0;
      fat = 0.2*max_fat;
      total_mass = mass+food+fat+muscle;

      decision_fraction = random(0.05, 0.2);
      int[] structure1 = {20, 15, 10, 7, 2};
      animal_analysis = new NeuralNet(structure1, "random", null);
      int[]structure2 = {7, 6, 5, 3, 1};
      tile_analysis = new NeuralNet(structure2, "random", null);
      int[]structure3 = {11, 8, 6, 2};
      decide = new NeuralNet(structure3, "random", null);
    }

    if (init == "mutate") {
      species = parent.species;
      x = parent.x;
      y=parent.y;
      current_tile = parent.current_tile;

      Attack = parent.Attack;
      Defence = parent.Defence;
      Defence_attack= parent.Defence_attack;

      Water_speed = parent.Water_speed;
      Land_speed= parent.Land_speed;

      conversion = parent.conversion;

      adult_mass = parent.adult_mass;

      decision_fraction = parent.decision_fraction;
      animal_analysis = new NeuralNet(parent.animal_analysis.structure, "mutate", parent.animal_analysis);
      tile_analysis = new NeuralNet(parent.tile_analysis.structure, "mutate", parent.tile_analysis);
      decide = new NeuralNet(parent.decide.structure, "mutate", parent.decide);

      species+=10000*(animal_analysis.mutate() + 100*tile_analysis.mutate() + decide.mutate());

      mutate();

      food = parent.food;
      water = parent.water;
      muscle = 0;//parent.muscle;
      fat = parent.fat;
    }
    get_stats();
  }

  float calculate_energy(String action) {
    float mult = 0*0.000001;
    switch(action) {
    case "Move":
      return mult*(0.3*mass + 0.5*muscle + 0.1*fat + 0.1*food);
    case "Eat":
      return mult*0.3*(0.3*mass + 0.5*muscle + 0.1*fat + 0.1*food);
    case "Attack":
      return mult*(0.3*mass + 0.5*muscle + 0.1*fat + 0.1*food);
    default:
      return 0;
    }
  }


  float[] Move(String init, float[] headding) {
    float[] pos = new float[2];

    float modifier;
    if (current_tile.type == "water") {
      modifier = Water_speed*(1+muscle/max_muscle)*(0.25+pow(mass, 2));
    } else {
      modifier = Land_speed*(1+muscle/max_muscle)*(0.25+pow(mass, 2));
    }

    switch(init) {
    case "random":
      seed = seed+0.1;
      dir = dir+0.75*(noise(seed)-0.5);
      x = x + 0.1*modifier*cos(dir);
      y = y + 0.1*modifier*sin(dir);
      break;
    case "towards":
      headding[0] += 0.01*randomGaussian();
      headding[1] += 0.01*randomGaussian();
      dir = atan2(headding[1], headding[0]);
      x = x + 0.1*modifier*cos(dir);
      y = y + 0.1*modifier*sin(dir);
      break;
    }

    pos[0] = x;
    pos[1] = y;
    Take_energy(calculate_energy("Move"));
    total_mass = mass+food+fat+muscle;
    get_stats();
    return pos;
  }

  void Eat(float quantity) {
    quantity = min(current_tile.Vegetation, quantity);
    current_tile.Vegetation -= quantity;

    float remainder;
    remainder = max(food+quantity-stomach_size*mass/adult_mass, 0);
    food = min(food+quantity, stomach_size*mass/adult_mass);
    if (remainder>0) {
      health = min(health +max_health*0.03, max_health);
    }


    quantity = remainder;
    remainder = max(mass+quantity-adult_mass, 0);
    mass = min(mass+quantity, adult_mass);

    quantity = remainder;
    fat = min(fat+remainder*conversion, max_fat);
    muscle = min(muscle+remainder*(1-conversion), max_muscle);

    Take_energy(calculate_energy("Eat"));
    total_mass = mass+food+fat+muscle;

    if (mass==adult_mass &&fat>=0.5*max_fat) {
      split=true;
    } else {
      split=false;
    }
    get_stats();
  }

  void Show() {
    fill(2*(species%100)+55, ((species/10)%100)+55, 2*((species/100)%100)+55);
    ellipse(tilesize*(x), tilesize*(y), tilesize*(sqrt(mass)), tilesize*(sqrt(mass)));
  }

  float Performance_factor() {
    return exp(2-age/50.0)-exp(2-age/25.0);
  }
  void Set(float[] pos, Tile tile) {
    x=pos[0];
    y=pos[1];
    current_tile = tile;
  }

  void Take_energy(float spent) {
    float remainder;
    remainder = max(spent-food, 0);
    food = max(food-spent, 0);

    spent = remainder;
    remainder = max(1.5*spent-fat, 0);
    fat = max(fat-1.5*spent, 0);

    spent = remainder;
    remainder = max(2*spent-muscle, 0);
    muscle = max(muscle-2*spent, 0);

    if (remainder>0) {
      die=true;
    }
  }

  void split_fn() {
    split = false;
    mass = mass*0.5;
    food = food*0.5;
    fat = fat*0.5;
    //muscle = muscle*0.5;
    total_mass = mass+food+fat+muscle;
    //age = 0;
  }

  void mutate() {
    float rate = 0.005;
    age = 0;
    dir = random(0, 1);
    seed = random(0, 100);
    split = false;
    die = false;

    float temp;
    Attack = Attack+pchange()*rate*randomGaussian();
    Defence = Defence+pchange()*rate*randomGaussian();
    Defence_attack=Defence_attack+pchange()*rate*randomGaussian();
    temp = Attack+Defence+Defence_attack;
    Attack = Attack/temp;
    Defence=Defence/temp;
    Defence_attack=Defence_attack/temp;

    Water_speed = max(Water_speed+pchange()*rate*randomGaussian(), 0);
    Land_speed=max(Land_speed+pchange()*rate*randomGaussian(), 0);
    temp = Water_speed+Land_speed;
    Water_speed = Water_speed/temp;
    Land_speed=Land_speed/temp;

    conversion = max(min(conversion + pchange()*rate*randomGaussian(), 1), 0);

    adult_mass =max(adult_mass*(1+pchange()*rate*randomGaussian()), 0.5);
    max_health = 1/(1+exp(-(adult_mass-0.5)*8));
    stomach_size = adult_mass/3;
    max_muscle=adult_mass;
    max_fat=adult_mass;
    total_mass = mass+food+fat+muscle;

    decision_fraction = min(decision_fraction+(pchange()+pchange())*rate*(1+randomGaussian()), 1);
  }

  float pchange() {
    if (random(0, 1)>0.01) {
      return 0;
    } else {
      species+=10000*floor(random(0,2))+100*floor(random(0,2))+floor(random(0,2));
      return 1;
    }
  }

  void get_stats() {
    stats[0] = Attack;
    stats[1] = Defence;
    stats[2] = Defence_attack;
    stats[3] = Land_speed;
    stats[4] = Water_speed;
    stats[5] = mass;
    stats[6] = muscle;
    stats[7] = fat;
    stats[8] = food;
    stats[9] = health;
  }
}
