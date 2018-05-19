import java.sql.*;

public class Assignment2 {
    
    // A connection to the database  
    Connection connection;
  
    // Statement to run queries
    Statement sql;
  
    // Prepared Statement
    PreparedStatement ps;
  
    // Resultset for the query
    ResultSet rs;
  
    //CONSTRUCTOR
    Assignment2(){
    }
  
    //Using the input parameters, establish a connection to be used for this session. Returns true if connection is sucessful
    public boolean connectDB(String URL, String username, String password){
        try{
            connection = DriverManager.getConnection(URL, username, password);
        }catch(SQLException ex){
            return false;
        }
        if(connection!=null){
            return true;
        }else{
            return false;
        }
    }
  
    //Closes the connection. Returns true if closure was sucessful
    public boolean disconnectDB(){
        try{
            connection.close();
            return true;
        }catch(SQLException ex){
            return false;
        }   
    }
    
    public boolean insertTeam(int eid, String ename, int cid) {
        try {
            sql = connection.createStatement(); 
            String sqlText = String.format("SELECT * FROM team WHERE Team.eid = %d", eid);
            rs = sql.executeQuery(sqlText);
            if ( rs != null ){
                if(rs.next()){
                    return false;
                }
            }

            sql = connection.createStatement();
            String sqlText2 = String.format("INSERT INTO team VALUES (%d, '%s', '%d')", eid, ename, cid);
            sql.executeUpdate(sqlText2);

            return true;
        } catch (SQLException ex) {
            return false;
        }   
    }
  
    public int getChampions(int eid) {
	      try{
            sql=connection.createStatement();
            
            String sqlText = String.format("SELECT * FROM team WHERE team.eid = %d", eid);
            rs = sql.executeQuery(sqlText);
            if ( rs != null ){
                if(rs.next()==false){
                    return -1;
                }
            }
            
            sqlText="SELECT count(*) AS count FROM champion WHERE champion.mid="+eid;
            rs=sql.executeQuery(sqlText);
            if(rs!=null){
                if(rs.next()){
                    return rs.getInt("count");
                }
                return 0;
            }
            return 0;

        }catch(SQLException ex){
            return 0;
        } 
    }
   
    public String getRinkInfo(int rid){
        try{
            sql=connection.createStatement();
            String sqlText="SELECT rinkid, rinkname, capacity, tournament.tname 
            FROM rink, tournament WHERE tournament.tid = rink.tid and rink.rinkid="+rid;
            rs=sql.executeQuery(sqlText);
            String newString="";
            if(rs!=null)
                if(rs.next())
                    newString=rs.getString(1)+":"+rs.getString(2)+":"+rs.getString(3)+":"+rs.getInt(4);
            return newString;
        }catch(SQLException ex){
            return "";
        }
    }

    public boolean chgRecord(int pid, int rank){
        try{
            sql = connection.createStatement();
            String sqlText2 = String.format("SELECT * FROM player WHERE player.pid='"+pid+"'");
            rs=sql.executeQuery(sqlText2);
            if(rs!=null){
                if(rs.next()){
                }else{
                    return false;
                }
            }else{
                return false;
            }
            
            sql=connection.createStatement();
            String sqlText="UPDATE player SET globalrank='"+rank+"' WHERE pid="+pid;
            sql.executeUpdate(sqlText);

            return true;
        }catch(SQLException ex){
            return false;
        }
    }

    public boolean deleteMatcBetween(int e1id, int e2id){
                try {
            sql = connection.createStatement();
            
            String sqlText = String.format("SELECT * FROM event 
                WHERE (winid = %d and lossid = %d) or (winid = %d and lossid = %d)", e1id, e2id, e2id, e1id);
            rs = sql.executeQuery(sqlText);
            if ( rs != null ){
                if(rs.next()==false){
                    return false;
                }
            }
                        
            sqlText = String.format("DELETE FROM event
             WHERE year <= 2015 and year >= 2011 and 
             (winid = %d and lossid = %d) or (winid = %d and lossid = %d)", e1id, e2id, e2id, e1id);
            sql.executeUpdate(sqlText);
            return true;
        } catch (SQLException ex) {
            return false;
        } 
    }
  
    public String listPlayerRanking(){
	      try{
            sql=connection.createStatement();
            String sqlText="SELECT DISTINCT pname, globalrank FROM player"
            rs=sql.executeQuery(sqlText);
            String newString="";
            if(rs!=null){
                if(rs.next()){
                    newString= rs.getString(1)+":"+rs.getString(2);
                }
                while(rs.next()){
                    newString= newString+"\n"+rs.getString(1)+":"+rs.getString(2);
                }
                return newString;
            }else{
                return newString;
            }
        }catch(SQLException ex){
            return "";
        }
    }
  
    public int findTriCircle(){
         try{
            sql=connection.createStatement();
            String sqlText="SELECT COUNT(DISTINCT t1.gname)"+
                    "        FROM TEAM t1, TEAM t2, TEAM t3, event e1, event e2, event e3" + 
                    "        WHERE e1.winid = t1.gid AND e1.lossid = t2.gid" + 
                    "        and e2.winid = t2.gid AND e2.lossid = t3.gid" + 
                    "        and e3.winid = t3.gid AND e3.lossid = t1.gid";
            rs=sql.executeQuery(sqlText);
            String newString="";
            if(rs!=null)
                return newString;
            return 0
        }catch(SQLException ex){
            return 0;
        }
    }
    
    public boolean updateDB(){
        // have to try this in mysql
	      try {
            sql = connection.createStatement();
            String sqlText =    "CREATE TABLE allTimeHomeWinners ( " +
                    "    pid INTEGER REFERENCES player(pid) ON DELETE RESTRICT, " +
                    "    tid INTEGER REFERENCES team(gid) ON DELETE RESTRICT, " +
                    "    pname VARCHAR(30) REFERENCES player(pname) ON DELETE RESTRICT, " +
                    "    city VARCHAR(30) city(cname) ON DELETE RESTRICT)";
            sql.executeUpdate(sqlText);
            String sqlText2 =   "INSERT INTO allTimeHomeWinners ( " +
                    "    SELECT player.pid, player.pname, team.gid, city.cname " +
                    "    FROM player, team, city, champion, tournament" +
                    "    WHERE player.tid = team.gid and team.cid = city.cid and champion.mid = team.gid" +
                    "    GROUP BY player.pname" +
                    "    HAVING count(DISTINCT champion.tid) = count(DISTINCT tournament.tid))";
            sql.executeUpdate(sqlText2);
            return true;
        } catch (SQLException ex) {
            return false;    
        }  
    }
    }  
}
