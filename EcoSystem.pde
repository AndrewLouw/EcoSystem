float tilesize = 10;
int Tileshigh;
int Tileswide;
Tile[] Tiles;
int animal_count = 500;
ArrayList<Animal> Animals = new ArrayList<Animal>();
int count;
int created_count;
int kill_count;
int total_created=0;
float updated =0;
int cout = 100;

int[][] surrounding_tiles = {{-1, -1}, {0, -1}, {1, -1}, 
  {-1, 0}, {1, 0}, 
  {-1, 1}, {0, 1}, {1, 1}, {0, 0}};

void setup() {
  size(1080, 720);
  noStroke();
  //fullScreen();
  count = 0;
  Tileswide = floor(width/tilesize);
  Tileshigh = floor(height/tilesize);
  Tiles = new Tile[Tileswide*Tileshigh];
  for (int i = 0; i<Tileshigh; i++) {
    for (int j = 0; j<Tileswide; j++) {
      String Type; 
      float noise_size=0.1;
      if (noise(i*noise_size, j*noise_size)>0.4) {
        if (noise(i*noise_size, j*noise_size)>0.7) {
          Type = "stone";
        } else {
          Type = "grass";
        }
      } else {
        Type = "water";
      }

      Tiles[j+i*(Tileswide)] = new Tile(Type, tilesize, j, i);
    }
  }  
  for (int i = 0; i<(Tileswide*Tileshigh); i++) {
    Tiles[i].Show();
  }

  for (int i = 0; i<animal_count; i++) {
    float[] pos = new float[2];
    pos[0] = floor(random(0, Tileswide));
    pos[1] = floor(random(0, Tileshigh));    
    Animals.add(new Animal("random", tilesize, null, total_created));
    total_created++;
    Animals.get(i).Set(pos, Tiles[floor(pos[0])+floor(pos[1])*(Tileswide)]);    
    Animals.get(i).current_tile.current_animals.add(Animals.get(i));
    Animals.get(i).Show();
  }
}

void draw() {
  background(255);
  for (int i = 0; i<Tileswide*Tileshigh; i++) {
    Tiles[i].Grow();
    Tiles[i].Show();
  }



  
  created_count = 0;
  kill_count = 0;

  for (int i = 0; i<Animals.size(); i++) {
    Animals.get(i).age++;
    if (Animals.get(i).age >200) {
      if (random(0, 1)<0.01) {
        Animals.get(i).die = true;
      }
    }
    if (Animals.get(i).die) {
      Animals.get(i).current_tile.Meat += Animals.get(i).total_mass;
      if (Animals.get(i).total_mass>0) {
        int index = Animals.get(i).current_tile.find_animal(Animals.get(i).unique_id);
        Animals.get(i).current_tile.current_animals.remove(index);
      }
      Animals.remove(i);
      kill_count++;
      animal_count--;
      i--;
    } else {
      if (Animals.get(i).split && random(0, 1)>(animal_count-200)/3000) {
        Animals.get(i).split_fn();
        Animals.add(new Animal("mutate", Animals.get(i).tilesize, Animals.get(i), total_created));
        Animals.get(Animals.size()-1).current_tile.current_animals.add(Animals.get(Animals.size()-1));
        total_created++;
        created_count++;
      }



      float[] dir = new float[2];
      int attack_id = -1;
      String action;
      if (random(0, 1)<Animals.get(i).decision_fraction) {
        updated+=1.0/(Animals.size()*cout);
        float[] options = new float[10];
        float attack_value = 0;
        for (int j=0; j<9; j++) {
          int x = floor(Animals.get(i).x) + surrounding_tiles[j][0];
          int y = floor(Animals.get(i).y) + surrounding_tiles[j][1];

          options[j] = 0;
          if (0<x && x<Tileswide) {
            if (0<y && y<Tileshigh) {
              Matrix animal_net = new Matrix(1, 2, "zeros");
              for (int k =0; k<Tiles[x+y*(Tileswide)].current_animals.size(); k++) {

                if (Tiles[x+y*(Tileswide)].current_animals.get(k).unique_id !=Animals.get(i).unique_id) {
                  Animals.get(i).get_stats();
                  float[]data =concat(Animals.get(i).stats, Tiles[x+y*(Tileswide)].current_animals.get(k).stats);

                  Matrix Data = new Matrix(1, data.length, "null");
                  Data.setrow(0, data);
                  Matrix output =Animals.get(i).animal_analysis.run(Data);
                  animal_net.add(output, true);

                  if (j==8) {
                    if (output.row(0)[0]>attack_value) {
                      attack_id=Tiles[x+y*(Tileswide)].current_animals.get(k).unique_id;
                      attack_value = output.row(0)[0];
                    }
                  }
                }
              }

              float tiletype = 0;
              switch(Tiles[x+y*(Tileswide)].type) {
              case "grass":
                tiletype=1;
                break;
              case "stone":
                tiletype=0.2;
                break;
              case "water":
                tiletype=-1;
                break;
              }
              float[] tiledata={tiletype, Tiles[x+y*(Tileswide)].Vegetation, Tiles[x+y*(Tileswide)].Max_Vegetation, Tiles[x+y*(Tileswide)].current_animals.size(), random(-0.001, 0.001)}; 
              if (j==9) {
                tiledata[3]--;
              }

              tiledata = concat(animal_net.row(0), tiledata);
              Matrix Data = new Matrix(1, tiledata.length, "null");
              Data.setrow(0, tiledata);
              options[j] = Animals.get(i).tile_analysis.run(Data).row(0)[0];
            }
          }
        }


        options[8] = options[8];
        options[9] = attack_value;
        options = append(options, 1-Animals.get(i).food);
        Matrix Data = new Matrix(1, options.length, "null");
        Data.setrow(0, options);
        float[] out  = Animals.get(i).decide.run(Data).row(0);
        options[8] = out[0];
        options[9] = out[1];
        options = shorten(options);

        int choice = maxindex(options, i);
        if (choice<8) {
          dir[0]= surrounding_tiles[choice][0];
          dir[1] =surrounding_tiles[choice][1];
          action = "Move";
        } else {
          if (choice ==9 && attack_id !=-1) {
            //println("animal wants to attack");
            action = "Attack";
          } else {
            action = "Eat";
          }
        }
      } else {
        if (random(0, 1)<0.6) {
          action = "Eat";
        } else
          action = "MoveR";
      }

      int index;
      float[] pos;
      switch(action) {
      case "Move":
        index = Animals.get(i).current_tile.find_animal(Animals.get(i).unique_id);
        Animals.get(i).current_tile.current_animals.remove(index);

        pos = new float[2];
        pos = Animals.get(i).Move("towards", dir);
        pos[0] = max(min(pos[0], Tileswide-1), 0);
        pos[1] = max(min(pos[1], Tileshigh-1), 0);
        Animals.get(i).Set(pos, Tiles[floor(pos[0])+floor(pos[1])*(Tileswide)]);
        Animals.get(i).current_tile.current_animals.add(Animals.get(i));
        break;
      case "MoveR":
        index = Animals.get(i).current_tile.find_animal(Animals.get(i).unique_id);
        Animals.get(i).current_tile.current_animals.remove(index);

        pos = new float[2];
        pos = Animals.get(i).Move("random", dir);
        pos[0] = max(min(pos[0], Tileswide-1), 0);
        pos[1] = max(min(pos[1], Tileshigh-1), 0);
        Animals.get(i).Set(pos, Tiles[floor(pos[0])+floor(pos[1])*(Tileswide)]);
        Animals.get(i).current_tile.current_animals.add(Animals.get(i));
        break;

      case "Eat":
        float meal_size = Animals.get(i).stomach_size*Animals.get(i).mass/Animals.get(i).adult_mass;
        meal_size = min(Animals.get(i).current_tile.Vegetation, meal_size);
        Animals.get(i).current_tile.Vegetation -= meal_size;
        Animals.get(i).Eat(meal_size);
        break;
      case "Attack":
        //println("an Attack is comming");
        int attack_index = Animals.get(i).current_tile.find_animal(attack_id);
        Animal target =  Animals.get(i).current_tile.current_animals.get(attack_index);
        Animals.get(i).health = Animals.get(i).health - target.Defence_attack*Animals.get(i).mass;
        target.health = target.health - max(Animals.get(i).mass*(1+Animals.get(i).muscle)*Animals.get(i).Attack*3 - target.mass*(1+Animals.get(i).muscle)*target.Defence, 0);       
        if (target.health<=0) {
          Animals.get(i).Eat(target.total_mass);
          attack_index = target.current_tile.find_animal(target.unique_id);
          target.current_tile.current_animals.remove(attack_index);
          target.total_mass = 0;
          target.die = true;
          target.current_tile.kill = 10;
        }
        if (Animals.get(i).health<=0) {
          attack_index = Animals.get(i).current_tile.find_animal(Animals.get(i).unique_id);
          Animals.get(i).current_tile.current_animals.remove(attack_index);
          Animals.get(i).total_mass = 0;
          Animals.get(i).die = true;
          //println("an Attack Happened and the attacker died");
        }
        Animals.get(i).Take_energy(Animals.get(i).calculate_energy("Attack"));
        Animals.get(i).get_stats();
        break;
      default:
        break;
      }
      Animals.get(i).Show();
    }
  }


  if (animal_count<200) {
    int to_make = 200-animal_count;
    for (int i = 0; i<to_make; i++) {
      float[] pos = new float[2];
      pos[0] = floor(random(0, Tileswide));
      pos[1] = floor(random(0, Tileshigh));    
      Animals.add(new Animal("random", tilesize, null, total_created));
      total_created++;
      animal_count++;
      Animals.get(Animals.size()-1).Set(pos, Tiles[floor(pos[0])+floor(pos[1])*(Tileswide)]);    
      Animals.get(Animals.size()-1).current_tile.current_animals.add(Animals.get(Animals.size()-1));
      Animals.get(Animals.size()-1).Show();
    }
  }

  animal_count+=created_count;

  if (count%cout==0) {
    println(count, ' ', Animals.size(), ' ', updated*100, ' ', frameRate);
    updated =0;
  }
  count++;
}

int maxindex(float[] input, int index) {
  int max = Animals.get(index).bias;
  for (int i = 0; i<input.length; i++) {
    if (input[i]>(input[max])) {
      max = i;
    }
  }
  Animals.get(index).bias = max;
  return max;
}
