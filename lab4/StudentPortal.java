/* This is the driving engine of the program. It parses the command-line
 * arguments and calls the appropriate methods in the other classes.
 *
 * You should edit this file in two ways:
 * 1) Insert your database username and password in the proper places.
 * 2) Implement the three functions getInformation, registerStudent
 *    and unregisterStudent.
 */
import java.sql.*; // JDBC stuff.
import java.util.Properties;
import java.util.Scanner;

import org.postgresql.util.PSQLException;

import java.io.*;  // Reading user input.

public class StudentPortal
{
    /* TODO Here you should put your database name, username and password */
    static final String DATABASE = "jdbc:postgresql://ate.ita.chalmers.se/";
    static final String USERNAME = "tda357_026";
    static final String PASSWORD = "pierreshang";

    /* Print command usage.
     * /!\ you don't need to change this function! */
    public static void usage () {
        System.out.println("Please choose a mode of operation:");
        System.out.println("    i[nformation]");
        System.out.println("    r[egister] <course>");
        System.out.println("    u[nregister] <course>");
        System.out.println("    q[uit]");
    }

    /* main: parses the input commands.
     * /!\ You don't need to change this function! */
    public static void main(String[] args) throws Exception
    {
        try {
            Class.forName("org.postgresql.Driver");
            String url = DATABASE;
            Properties props = new Properties();
            props.setProperty("user",USERNAME);
            props.setProperty("password",PASSWORD);
            Connection conn = DriverManager.getConnection(url, props);

            String student = args[0]; // This is the identifier for the student.

        //   Console console = System.console();
	    // In Eclipse. System.console() returns null due to a bug (https://bugs.eclipse.org/bugs/show_bug.cgi?id=122429)
	    // In that case, use the following line instead:
            BufferedReader console = new BufferedReader(new InputStreamReader(System.in));
            System.out.println("Welcome!");
            usage();
            while(true) {
	        System.out.print("? > ");
                String mode = console.readLine();
                String[] cmd = mode.split(" +");
                cmd[0] = cmd[0].toLowerCase();
                if ("information".startsWith(cmd[0]) && cmd.length == 1) {
                    /* Information mode */
                    getInformation(conn, student);
                } else if ("register".startsWith(cmd[0]) && cmd.length == 2) {
                    /* Register student mode */
                    registerStudent(conn, student, cmd[1]);
                } else if ("unregister".startsWith(cmd[0]) && cmd.length == 2) {
                    /* Unregister student mode */
                    unregisterStudent(conn, student, cmd[1]);
                } else if ("quit".startsWith(cmd[0])) {
                    break;
                } else usage();
            }
            System.out.println("Goodbye!");
            conn.close();
        } catch (SQLException e) {
            System.err.println(e);
            System.exit(2);
        }
    }

    /* Given a student identification number, this function should print
     * - the name of the student, the students national identification number
     *   and their issued login name (something similar to a CID)
     * - the program and branch (if any) that the student is following.
     * - the courses that the student has read, along with the grade.
     * - the courses that the student is registered to. (queue position if the student is waiting for the course)
     * - the number of mandatory courses that the student has yet to read.
     * - whether or not the student fulfills the requirements for graduation
     */
    static void getInformation(Connection conn, String student) throws SQLException
    {
    	int ssn = 0;
    	try {
    		ssn = Integer.parseInt(student);
    	} catch (NumberFormatException e) {
    		System.out.println("Error: "+e+", not a number.");
    	} 
    	String sql = "SELECT ssn, name, login, program FROM Student WHERE ssn = ?";
    	PreparedStatement ps = conn.prepareStatement(sql);
    	ps.setInt(1,ssn);
    	ResultSet rs = ps.executeQuery();
    	if(rs.next()) 
    		System.out.print("Student: "+rs.getString(1)+" Name: "+rs.getString(2)+
    				" Login: "+rs.getString(3)+"\nProgram: "+rs.getString(4));
    	
    	sql = "SELECT branch FROM StudentsFollowing WHERE student = ?";
    	ps = conn.prepareStatement(sql);
    	ps.setInt(1,ssn);
    	rs = ps.executeQuery();
    	if(rs.next())
    		System.out.println(" Branch: "+rs.getString(1));
    	
    	sql = "SELECT course, grade FROM FinishedCourses WHERE student = ?";
    	ps = conn.prepareStatement(sql);
    	ps.setInt(1,ssn);
    	rs = ps.executeQuery();
    	System.out.println("");
    	System.out.println("Read courses:");
    //	if(!rs.next())
    //		System.out.println(" No read course");
    	while(rs.next())
    		System.out.println(" Course: "+rs.getString(1)+" | Grade: "+rs.getString(2));
    	
    	sql = "SELECT course, status FROM Registrations WHERE student = ?";
    	ps = conn.prepareStatement(sql);
    	ps.setInt(1,ssn);
    	rs = ps.executeQuery();
    	System.out.println("");
    	System.out.println("Registered courses:");
    //	if(!rs.next())
    //		System.out.println(" No registered course");
    	while(rs.next()) {
    		if(rs.getString(2).compareTo("registered") == 0)
    			System.out.println(" Course: "+rs.getString(1)+" | Status: registered");
    		else {
    			sql = "SELECT position FROM CourseQueuePositions WHERE student = ? "
    					+ "AND course = "+Integer.parseInt(rs.getString(1));
    	    	ps = conn.prepareStatement(sql);
    	    	ps.setInt(1,ssn);
    	    	ResultSet rsBis = ps.executeQuery();
    	    	rsBis = ps.executeQuery();
    	    	rsBis.next();
    	    	System.out.println(" Course: "+rs.getString(1)+" | Status: waiting at position "+rsBis.getString(1));
    	    	rsBis.close();
    		}
    	}		
    	sql = "SELECT mandatoryleft, status FROM PathToGraduation WHERE student = ?";
    	ps = conn.prepareStatement(sql);
    	ps.setInt(1,ssn);
    	rs = ps.executeQuery();
    	System.out.println("");
    	System.out.println("Mandatories courses left:");
    //	if(!rs.next())
    //		System.out.println(" No mandatory course left");
    	while(rs.next()) {
    		String status = "";
    		if(rs.getString(2).compareTo("t") == 0) 
    			status = "OK for graduation";
    		else
    			status = "Not OK for graduation";
    		System.out.println(" Number of mandatory course(s) left: "+rs.getString(1)+" | Status: "+status);
    	}
    	rs.close();
    	ps.close();
    
    }

    /* Register: Given a student id number and a course code, this function
     * should try to register the student for that course.
     */
    static void registerStudent(Connection conn, String student, String course)
    throws SQLException
    {
    	try {
	    	PreparedStatement ps = conn.prepareStatement("INSERT INTO Registrations VALUES (?,?,?)");
	    	ps.setInt(1, Integer.parseInt(student));
	    	ps.setInt(2, Integer.parseInt(course));
	    	ps.setString(3, null);
	    	ps.executeUpdate();
	    	System.out.println(ps.getWarnings().getMessage());
	    	ps.close();
    	} catch (PSQLException e) {
    		System.out.println(e.getMessage());
    	} catch (NumberFormatException e) {
    		System.out.println("Error :"+e+", not a number.");
    	} 
    }

    /* Unregister: Given a student id number and a course code, this function
     * should unregister the student from that course.
     */
    static void unregisterStudent(Connection conn, String student, String course)
    throws SQLException
    {
    	try {
	    	PreparedStatement ps = conn.prepareStatement("DELETE FROM Registrations WHERE student = ? AND course = ?");
	    	ps.setInt(1, Integer.parseInt(student));
	    	ps.setInt(2, Integer.parseInt(course));
	    	ps.executeUpdate();
	    	System.out.println(ps.getWarnings().getMessage());
	    	ps.close();
    	} catch (PSQLException e) {
    		System.out.println(e.getMessage());
    	} catch (NumberFormatException e) {
    		System.out.println("Error :"+e+", not a number.");
    	} catch(NullPointerException e) {
    		System.out.println("Student "+student+" has already been unregistered from the course"+course);
    	}
    }
}
