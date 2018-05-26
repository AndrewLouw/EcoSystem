class Matrix { //<>//
  int rows;
  int columns;
  float[][] values;
  Matrix(int r, int c, String init) {
    rows = r;
    columns=c;
    values =new float[rows][columns];
    switch(init) {
    case "zeros":
      for (int i=0; i<rows; i++) {
        for (int j=0; j<columns; j++) {
          values[i][j] = 0;
        }
      }
      break;
    case "ones":
      for (int i=0; i<rows; i++) {
        for (int j=0; j<columns; j++) {
          values[i][j] = 1;
        }
      }
      break;
    case "rand":
      for (int i=0; i<rows; i++) {
        for (int j=0; j<columns; j++) {
          values[i][j] = random(0, 1);
        }
      }
      break;
    case "randg":
      for (int i=0; i<rows; i++) {
        for (int j=0; j<columns; j++) {
          values[i][j] = randomGaussian();
        }
      }
      break;
    }
  }

  Matrix adds(float addor, boolean inplace) {
    Matrix temp; 
    if (inplace) {
      temp = this;
    } else {
      temp = new Matrix(rows, columns, "null");
    }

    for (int i=0; i<temp.rows; i++) {
      for (int j=0; j<temp.columns; j++) {
        values[i][j]=temp.values[i][j]+addor;
      }
    }
    return temp;
  }

  Matrix mults(float addor, boolean inplace) {
    Matrix temp; 
    if (inplace) {
      temp = this;
    } else {
      temp = new Matrix(rows, columns, "null");
    }

    for (int i=0; i<temp.rows; i++) {
      for (int j=0; j<temp.columns; j++) {
        values[i][j]=temp.values[i][j]* addor;
      }
    }
    return temp;
  }

  Matrix add(Matrix addor, boolean inplace) {
    Matrix temp;  //<>//
    if (inplace) {
      temp = this;
    } else {
      temp = new Matrix(rows, columns, "null");
    }    

    String type;

    if (addor.rows==rows) {
      if (addor.columns==columns) {
        type = "elementwise";
      } else {
        type = "rowwise";
      }
    } else {
      if (addor.columns==columns) {
        type = "columnwise";
      } else {
        println("Input must have the same number or rows or columns as Matrix");
        return this;
      }
    }

    switch(type) {
    case "elementwise":
      for (int i=0; i<temp.rows; i++) {
        for (int j=0; j<temp.columns; j++) {
          temp.values[i][j]= values[i][j] + addor.values[i][j];
        }
      }
      break;

    case "rowwise":
      for (int i=0; i<temp.rows; i++) {
        for (int j=0; j<temp.columns; j++) {
          temp.values[i][j]= values[i][j] +addor.values[i][j%addor.columns];
        }
      }
      break;

    case "columnwise":
      for (int i=0; i<temp.rows; i++) {
        for (int j=0; j<temp.columns; j++) {
          temp.values[i][j]= values[i][j] +addor.values[i%addor.rows][j];
        }
      }
      break;
    }
    return temp;
  }

  Matrix mult(Matrix multor, boolean inplace) {
    Matrix temp = new Matrix(rows, multor.columns, "null"); 

    if (multor.rows!=columns) {
      println("Input rows must equal Matrix columns");
      return this;
    } else {
      for (int i=0; i<temp.rows; i++) {
        for (int j=0; j<temp.columns; j++) {
          for (int k=0; k<columns; k++) {
            temp.values[i][j]+= values[i][k] * multor.values[k][j];
          }
        }
      }
      if (inplace) {
        rows=temp.rows;
        columns=temp.columns;
        values = temp.values;
      }
      return temp;
    }
  }

  Matrix trans() {
    Matrix temp =new Matrix(columns, rows, "null");
    for (int i=0; i<temp.rows; i++) {
      for (int j=0; j<temp.columns; j++) {
        temp.values[i][j]=values[j][i];
      }
    }
    return temp;
  }

  Matrix copy() {
    Matrix temp =new Matrix(columns, rows, "null");
    temp.rows = rows;
    temp.columns = columns;
    temp.values = values.clone();
    return temp;
  }

  Matrix concat(Matrix data, int axis) {
    Matrix temp; 
    switch(axis) {
    case 0:
      if (data.columns !=columns) {
        println("Data columns must equal Matrix columns");
        return this;
      } else {
        temp = new Matrix(rows+data.rows, columns, "null");
        for (int i=0; i<rows; i++) {
          for (int j=0; j<temp.columns; j++) {
            temp.values[i][j] = values[i][j];
          }
        }
        for (int i=0; i<data.rows; i++) {
          for (int j=0; j<temp.columns; j++) {
            temp.values[i+rows][j] = data.values[i][j];
          }
        }
        return temp;
      }
    case 1: 
      if (data.columns !=columns) {
        println("Data rows must equal Matrix rows");
        return this;
      } else {
        temp = new Matrix(rows, columns+data.columns, "null");
        for (int i=0; i<temp.rows; i++) {
          for (int j=0; j<columns; j++) {
            temp.values[i][j] = values[i][j];
          }
        }
        for (int i=0; i<temp.rows; i++) {
          for (int j=0; j<data.columns; j++) {
            temp.values[i][j+columns] = data.values[i][j];
          }
        }
        return temp;
      }
    default:
      println("axis must be 0 (horizontal) or 1 (verical)");
      return this;
    }
  }

  float[] row(int i) {
    float[] temp = values[i].clone();
    return temp;
  }
  float[] column(int j) {
    float[] temp=new float[rows];
    for (int i=0; i<rows; i++) {
      temp[i] = values[i][j];
    }
    return temp;
  }
  void setrow(int i, float[] data) {
    if (data.length !=columns) {
      println("Data length must equal Matrix columns");
    } else {
      values[i] = data.clone();
    }
  }
  void setcolumn(int j, float[] data) {
    if (data.length !=rows) {
      println("Data length must equal Matrix columns");
    } else {
      for (int i=0; i<rows; i++) {
        values[i][j] = data[i];
      }
    }
  }
}
