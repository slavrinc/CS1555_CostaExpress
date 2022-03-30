import java.sql.*;
import java.util.Properties;
import java.io.*;
import java.util.ArrayList;

public class InsertData {
    public static void main(String args[]) throws
            SQLException, ClassNotFoundException, IOException {
					
		// Necessary for connection to db
        Class.forName("org.postgresql.Driver");
        String url = "jdbc:postgresql://localhost:5432/";
        Properties props = new Properties();
        props.setProperty("user", "postgres");
        props.setProperty("password", "addyourpasswordhere!"); //add your password for SQL functions, not working yet! but still need to add to test DB connection
        Connection conn =
                DriverManager.getConnection(url, props);

        Statement st = conn.createStatement(); //SQL statement to run
		
		
		String tableName = null;
		String[] attributeNames;
		String attributeReturnString = null;
		
		//parse file
		String file = "AllData.txt";
		BufferedReader bufferedReader = new BufferedReader(new FileReader(file));
		
		String currentLine;
		
		while ((currentLine = bufferedReader.readLine()) != null){
			
			if (!currentLine.contains("****")){ //if string is not a line of ****
				
				if (currentLine.contains("***")){ //if string contains *** it is either the tableName or format
				
					StringBuilder workingLine = new StringBuilder();
					workingLine.append(currentLine);
					
					if (currentLine.contains(".")){ //if line contains ".", it is the tableName line
						
						workingLine.delete(0, 4); //delete ***
						int periodLocation = workingLine.indexOf("."); //find period
						int lineLength = workingLine.length();
						workingLine.delete(periodLocation, lineLength); //delete everything from . to end of line
						

						tableName = workingLine.toString();
						
						tableName = tableName.replaceAll(" ", "_");
						
						System.out.println("Table: " + tableName); // test if table names are correctly formatted with underscores
						
						
					} else { //if line does not contain ".", it is the formatting line
						
						workingLine.delete(0, 4); //delete ***
						
						if ((tableName.compareToIgnoreCase("Railroad_lines") == 0) || (tableName.compareToIgnoreCase("Routes") == 0)){
							String tmpAttributes = workingLine.toString();
							
							
							//handling for routes and railroad lines
							int carrotLocation = tmpAttributes.indexOf("<");
							
							workingLine.delete(carrotLocation, workingLine.length());
							tmpAttributes = workingLine.toString();
							
							tmpAttributes = tmpAttributes.replaceAll(" ", ", ");
							
							workingLine.delete(0,workingLine.length());
							workingLine = workingLine.append(tmpAttributes);
							workingLine.delete(workingLine.length()-2, workingLine.length());
							
							attributeReturnString = workingLine.toString();
							
							System.out.println("Attributes: " + attributeReturnString); 
							
							
						} else {
							String tmpAttributes = workingLine.toString();
							tmpAttributes = tmpAttributes.replaceAll(" ", "_");
						
							attributeNames = tmpAttributes.split(";", 8);
						
							for (String a : attributeNames) { //check for ID presented as "ID" and update with table name
								if (a.compareToIgnoreCase("ID") == 0){
									StringBuilder changeIDName = new StringBuilder();
									changeIDName = changeIDName.append(tableName);
									changeIDName = changeIDName.deleteCharAt(changeIDName.length()-1);
									changeIDName = changeIDName.append(a);
									a = changeIDName.toString();
									attributeNames[0] = a;
									
								}
								
							}
							
							//make string with all attributes separated by a comma
							StringBuilder attributeStringBuilder = new StringBuilder();
							
							for (String a: attributeNames) {
								attributeStringBuilder.append(a);
								attributeStringBuilder.append(", ");
							}
							
							attributeStringBuilder.delete(attributeStringBuilder.length()-2, attributeStringBuilder.length());
							
							System.out.println("Attributes: " + attributeStringBuilder);
							
							//need to return string, not sb
							attributeReturnString = attributeStringBuilder.toString();
							
							
						}
						

					}
									
					
				} else { //currentLine is actual input data.
					
					//separate routes and raillines because they have different handling
					if ((tableName.compareToIgnoreCase("Routes") == 0) | (tableName.compareToIgnoreCase("Railroad_lines") == 0)){
						//if the data belongs to either Routes or Railroad_lines
						
						if(tableName.compareToIgnoreCase("Routes") == 0) {
							//format route data
							String[] tmpRouteStopsData = currentLine.split("Stations:"); //tmpRouteLineData[0] = Route: 22; tmpRouteLineData[1] = 1,2,3,... Stops: 1, 2, 3, ...
							
							String[] tmpRouteData = tmpRouteStopsData[0].split(": ");
							
							String routeNumber = tmpRouteData[1];
							routeNumber = routeNumber.replaceAll(" ", "");
							
							
							StringBuilder insertStatementRoute = new StringBuilder();
							insertStatementRoute.append("INSERT INTO ");
							insertStatementRoute.append(tableName);
							insertStatementRoute.append(" (");
							insertStatementRoute.append(attributeReturnString);
							insertStatementRoute.append(") VALUES (");
							insertStatementRoute.append(routeNumber);
							insertStatementRoute.append(");");
							
							System.out.println(insertStatementRoute); //////////////////////////////////////////////////INSERT STATEMENT
						
							String[] tmpStationStopsData = tmpRouteStopsData[1].split("Stops:");

							
							String[] tmpStopsData = tmpStationStopsData[1].split(","); //container of Stops that this route uses
							for(String a: tmpStopsData){
								a = a.replaceAll(" ", "");
							}
							
							tmpStopsData[tmpStopsData.length-1] = tmpStopsData[tmpStopsData.length-1].replaceAll(" ", "");
							
							String[] tmpStationsData = tmpStationStopsData[0].split(","); //container of Stations that this route passes
							for(String a: tmpStationsData){
								a = a.replaceAll(" ", "");
							}

							tmpStationsData[tmpStationsData.length-1] = tmpStationsData[tmpStationsData.length-1].replaceAll(" ", "");
							
							String stationNumber = null;
							String stopNumber = null;

							
							for(int w = 0; w <= tmpStationsData.length-1; w++) {
								boolean isStop = false;
								stationNumber = tmpStationsData[w];

								
								for(int x = 0; x <= tmpStopsData.length-1; x++){
								
									if (tmpStopsData[x].compareToIgnoreCase(tmpStationsData[w]) == 0){
										isStop = true;
										//break;
									}
								}
								
								StringBuilder insertStatementRouteInclude = new StringBuilder();
								insertStatementRouteInclude.append("INSERT INTO RouteInclude (route_id, station_id, stop) VALUES (");
								insertStatementRouteInclude.append(routeNumber);
								insertStatementRouteInclude.append(", ");
								insertStatementRouteInclude.append(stationNumber);
								insertStatementRouteInclude.append(", ");
								insertStatementRouteInclude.append(isStop);
								insertStatementRouteInclude.append(");");
								
								System.out.println(insertStatementRouteInclude); /////////////////////////////////////////////INSERT STATEMENT
								
								
							}
								
						}
						
						if(tableName.compareToIgnoreCase("Railroad_lines") == 0){
							//format railroad lines data
							String[] tmpRRLineData = currentLine.split("Stations:"); //tmpRRLineData[0] = LineID and Speed Limit; tmpRRLineData[1] = Station and Distance List

							
							String[] tmpLineIDSpeedLimit = tmpRRLineData[0].split(" ");

							
							String lineID = (tmpLineIDSpeedLimit[2]);
							String speedLimit = (tmpLineIDSpeedLimit[5]);
							
							StringBuilder rrLineInfo = new StringBuilder();
							rrLineInfo.append("(");
							rrLineInfo.append(lineID);
							rrLineInfo.append(", ");
							rrLineInfo.append(speedLimit);
							rrLineInfo.append(")");
							
							String rrLineInfoString = rrLineInfo.toString();
							
							StringBuilder insertStatementRR = new StringBuilder();
							insertStatementRR.append("INSERT INTO ");
							insertStatementRR.append(tableName);
							insertStatementRR.append(" (");
							insertStatementRR.append(attributeReturnString);
							insertStatementRR.append(") VALUES ");
							insertStatementRR.append(rrLineInfoString);
							insertStatementRR.append(";");
							
							System.out.println(insertStatementRR); /////////////////////////////////////////INSERT STATEMENT
							
							
							String[] tmpStationDistances = tmpRRLineData[1].split("Distances:"); //tmpStationDistances[0] = Stations; tmpStationDistances[1] = Distances
							

							String[] tmpStations = tmpStationDistances[0].split(",");
							
							
							for (String a: tmpStations){  //container of stations
								a = a.replaceAll(" ", "");
							}

							String[] tmpDistances = tmpStationDistances[1].split(",");
						
						
							for (String a: tmpDistances){ //container of distances
								a = a.replaceAll(" ", "");
						
							}
							
							String stationA = null;
							String stationB = null;
							String distance = null;
							String startStation = tmpStations[0];
							
							
							for(int k = 0; k < tmpStations.length-1; k++){

								stationA = tmpStations[k];
								stationB = tmpStations[k+1];
								distance = tmpDistances[k+1];
								
								
								StringBuilder insertStatementDistances = new StringBuilder();
								insertStatementDistances.append("INSERT INTO Distance (station_a, station_b, miles) VALUES (");
								insertStatementDistances.append(stationA);
								insertStatementDistances.append(", ");
								insertStatementDistances.append(stationB);
								insertStatementDistances.append(", ");
								insertStatementDistances.append(distance);
								insertStatementDistances.append(");");
								
								System.out.println(insertStatementDistances); ////////////////////////////////////////////INSERT STATEMENT
								
								
								StringBuilder insertStatementLineInclude = new StringBuilder();
								insertStatementLineInclude.append("INSERT INTO Line_Include (station_a, station_b, rail_id) VALUES (");
								insertStatementLineInclude.append(stationA);
								insertStatementLineInclude.append(", ");
								insertStatementLineInclude.append(stationB);
								insertStatementLineInclude.append(", ");
								insertStatementLineInclude.append(lineID);
								insertStatementLineInclude.append(");");
								
								System.out.println(insertStatementLineInclude); //////////////////////////////////////////////INSERT STATEMENT
								
							}
							
							
						}
						
						
					} else {
						//everything else
						currentLine = currentLine.replaceAll(";", ", ");

						StringBuilder insertStatement = new StringBuilder();
						insertStatement.append("INSERT INTO");
						insertStatement.append(" ");
						insertStatement.append(tableName);
						insertStatement.append(" (");
						insertStatement.append(attributeReturnString);
						insertStatement.append(") VALUES (");
						insertStatement.append(currentLine);
						insertStatement.append(");");
						
						System.out.println(insertStatement); ////////////////////////////////////////////////INSERTSTATEMENT
						
					}
					
					
				}
				
				
			} else { // if string is a line of ****, skip
				// do nothing, just here to remind me not to do anything
			}
			
			
			
			
		}
		
		bufferedReader.close();
		
		
		
		/*
        try {
            conn.setAutoCommit(false);
            st.executeUpdate("INSERT INTO recitation9.student (sid, name, class, major) VALUES ('145', 'Marios', 3, 'CS');");
            st.executeUpdate("INSERT INTO recitation9.student (sid, name, class, major) VALUES ('156', 'Andreas', 3, 'CS');");
            conn.commit();
        } catch (SQLException e1) {
            try {
                conn.rollback();
            } catch (SQLException e2) {
                System.out.println(e2.toString());
            }
        }
		*/


    }
}
