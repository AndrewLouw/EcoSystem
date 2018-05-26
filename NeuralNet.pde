class NeuralNet {
  int[] structure;
  int mutations;
  Matrix[][] parameters;

  NeuralNet(int[] struct, String init, NeuralNet parent) {
    structure = struct;
    parameters = new Matrix[structure.length-1][2];
    switch(init) {
    case "random":
      for (int i = 0; i < (structure.length-1); i++) {
        parameters[i][0] = new Matrix(structure[i], structure[i+1], "randg");
        parameters[i][1] = new Matrix(1, structure[i+1], "randg");
      }
      break;
    case "mutate":
      for (int i = 0; i < structure.length-1; i++) {
        parameters[i][0] = parent.parameters[i][0].copy();
        parameters[i][1] = parent.parameters[i][0].copy();
      }
      break;
    }
  }
  int mutate() {
    mutations = 0;
    for (int i = 0; i < structure.length-1; i++) {
      float rate = 0.005;
      Matrix temp;
      temp = new Matrix(parameters[i][0].rows, parameters[i][0].columns, "randG");
      temp.mults(pchange()*rate, true);
      parameters[i][0] = parameters[i][0].add(temp, true);

      temp = new Matrix(parameters[i][0].rows, parameters[i][0].columns, "randG");
      temp.mults(pchange()*rate, true);
      parameters[i][1] = parameters[i][0].add(temp, true); 
    }
    return mutations;
  }

  float pchange() {
    if (random(0, 1)>0.01) {
      mutations++;
      return 0;
    } else {
      return 1;
    }
  }

  Matrix run(Matrix y) {
    for (int layer = 0; layer<structure.length-1; layer++) {
      y = y.mult(parameters[layer][0], true);
      y = y.add(parameters[layer][1], true);
      for (int i = 0; i < y.rows; i++) {
        for (int j = 0; j < y.columns; j++) {
          y.values[i][j] = tanh(y.values[i][j]);
        }
      }
    }  
    return y;
  }

  float tanh(float z) {
    return (exp(z)-exp(-z))/(exp(z)+exp(-z));
  }
}
