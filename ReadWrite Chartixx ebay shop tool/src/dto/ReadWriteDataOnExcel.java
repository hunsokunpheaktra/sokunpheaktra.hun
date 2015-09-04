package dto;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpException;
import org.apache.commons.httpclient.HttpStatus;
import org.apache.commons.httpclient.methods.GetMethod;

import jxl.CellType;
import jxl.LabelCell;
import jxl.NumberCell;
import jxl.Sheet;
import jxl.Workbook;
import jxl.WorkbookSettings;
import jxl.read.biff.BiffException;
import jxl.write.WritableSheet;
import jxl.write.WritableWorkbook;
import jxl.write.WriteException;

public class ReadWriteDataOnExcel {
	
	static ArrayList<Data>listDatas = new ArrayList<Data>();
	static Map<String, String>mapImage;
	
	static{
		Map<String, String> aMap = new HashMap<String, String>();
        aMap.put("http://www.etope.de/programm/etope7.jpg", "etope");
        aMap.put("//static.afterbuy.de/afterbuy/images/banner4_logoab.jpg", "afterbuy");
        aMap.put("http://pics.ebay.com/aw/pics/de/sellingmanager/sellingmanagerPro/smPro_248x50.gif", "eBay Verkaufsmanager Pro");
        aMap.put("http://pics.ebay.com/aw/pics/sell/templates/images/k2/tagline.gif", "eBay Turbo Lister");
        aMap.put("http://image.channeladvisor.de/auktionmaster.gif", "ChannelAdvisor");
        aMap.put("http://www.kawi-trading.de/images/icons/powered_by_plenty_shop.gif", "plentyMarkets");
        aMap.put("http://storage.supremeauction.com/flash/htmlModules/supremeFooterGallery.gif", "Supreme Auction");
        aMap.put("http://www.dreamrobot.de/images/datenschutz/datenschutz_dr_logo.png", "DreamRobot");
        aMap.put("http://images.speed4trade.de/s4t/s4t_ds.png", "Speed4Trade");
        mapImage = Collections.unmodifiableMap(aMap);
	}
	
	public static List<String> findEbayTool(String url){
		
		// Create an instance of HttpClient.
		HttpClient client = new HttpClient();
		// Create a method instance.
		GetMethod method = new GetMethod(url);
		ArrayList<String> listTool = new ArrayList<String>();
		
		try {

			// Execute the method
			int statusCode = client.executeMethod(method);

			if (statusCode != HttpStatus.SC_OK) {
				System.err.println("Method failed: " + method.getStatusLine());
			}

			org.jsoup.nodes.Document doc = Jsoup.parse(new String(method
					.getResponseBody()));
			
			Elements lstShop = doc.getElementById("CenterPanel").getElementsByClass("li");
			
			if(lstShop.size() > 0){
			
				try{
					String u = lstShop.get(0).getElementsByClass("ttl").get(0).getElementsByTag("a").get(0).attr("href");
					listTool = getShopTool(u);
					return listTool;
					
				}catch(IndexOutOfBoundsException e){
					
					e.printStackTrace();
					System.out.println(url);
				}
			}

		} catch (HttpException e) {
			System.err.println("Fatal protocol violation: " + e.getMessage());
			e.printStackTrace();
		} catch (IOException e) {
			System.err.println("Fatal transport error: " + e.getMessage());
			e.printStackTrace();
		
		} finally {
			// Release the connection.
			method.releaseConnection();

		}
		
		return listTool;
	}
	
	public static ArrayList<String> getShopTool(String url){
		
		// Create an instance of HttpClient.
		HttpClient client = new HttpClient();
		// Create a method instance.
		GetMethod method = new GetMethod(url);
		
		ArrayList<String>listTool = new ArrayList<String>();
		
		try {

			// Execute the method
			int statusCode = client.executeMethod(method);

			if (statusCode != HttpStatus.SC_OK) {
				System.err.println("Method failed: " + method.getStatusLine());
			}

			org.jsoup.nodes.Document doc = Jsoup.parse(new String(method.getResponseBody()));
			Elements element1 = doc.getElementsByTag("img");
			Elements element2 = doc.getElementById("vi-content").getElementsByTag("img");
		
			for(int i=0;i<element1.size();i++){
				String tool = element1.get(i).attr("src");		
				if(mapImage.containsKey(tool)){
					if(!listTool.contains(mapImage.get(tool))){
						listTool.add(mapImage.get(tool));
					}
				}
				
			}
			
			for(int i=0;i<element2.size();i++){
				String tool = element2.get(i).attr("src");
				if(mapImage.containsKey(tool)){
					if(!listTool.contains(mapImage.get(tool))){
						listTool.add(mapImage.get(tool));
					}
				}
			}
			
			return listTool;

		} catch (HttpException e) {
			System.err.println("Fatal protocol violation: " + e.getMessage());
			e.printStackTrace();
		} catch (IOException e) {
			System.err.println("Fatal transport error: " + e.getMessage());
			e.printStackTrace();
		
		}catch (NullPointerException e){	
			return listTool;
		} finally {
			// Release the connection.
			method.releaseConnection();

		}
		
		return null;
		
	}
	
	public static void WriteDataToExcel(){
		
		File f = new File("chartixx ebaytool capture copy.xls");
		WritableWorkbook workbook = null;
		WritableSheet s = null;
		Workbook w = null;
		WorkbookSettings ws = new WorkbookSettings();
		ws.setEncoding("CP1250");
		
		try {
			
			if (f.exists()) {
				
				w = Workbook.getWorkbook(f,ws);
				workbook = Workbook.createWorkbook(f, w);
				s = workbook.getSheet(0);
				
			}
			else{
			
				workbook = Workbook.createWorkbook(f,ws);
				s = workbook.createSheet("NewSheet", 0);
				
				s.addCell(new jxl.write.Label(0, 0, "ID"));
				s.addCell(new jxl.write.Label(1, 0, "EBAY_NAME_LINK__C"));
				s.addCell(new jxl.write.Label(2, 0, "EBAY_NAME__C"));
				s.addCell(new jxl.write.Label(3, 0, "EBAY_SHOP_NAME__C"));
				s.addCell(new jxl.write.Label(4, 0, "EBAY_SHOP_TOOL__C"));
				
			}
			
			for(Data data:listDatas){
				
//				s.addCell(new jxl.write.Label(0,row,data.getId()));
//				s.addCell(new jxl.write.Label(1,row,data.getLink()));
//				s.addCell(new jxl.write.Label(2,row,data.getName()));
//				s.addCell(new jxl.write.Label(3,row,data.getShopName()));
				s.addCell(new jxl.write.Label(4,data.getIndex(),data.getShopTool()));
				
			}
			workbook.write();
			listDatas.clear();
			workbook.close();
			
		} catch (IOException e) {
			e.printStackTrace();
		} catch (WriteException e) {
			e.printStackTrace();
		}catch (BiffException e) {
			e.printStackTrace();
		}
		
		
	}
	
	public static void main(String [] argvs){
		
		try {
			
			WorkbookSettings ws = new WorkbookSettings();
		    ws.setEncoding("CP1250");
		    Workbook w = Workbook.getWorkbook(new File("chartixx ebaytool capture.xls"));
		    Sheet s = w.getSheet(0);
		    
		    for(int i=0;i<s.getRows();i++){
		    	
		    	Data d = new Data();
		    	d.setId(s.getCell(0,i).getContents());
		    	d.setLink(s.getCell(1,i).getContents());
		    	d.setName(s.getCell(2,i).getContents());
		    	d.setShopName(s.getCell(3,i).getContents());
		    	d.setShopTool(s.getCell(4,i).getContents());
		    	
		    	String shopTool = "";
		    	
		    	if(s.getCell(1,i).getType() != CellType.EMPTY){
		    		LabelCell lc1 = (LabelCell)s.getCell(1, i);
		    		if(!d.getLink().trim().equals("")){
		    			List<String>listTool = findEbayTool(lc1.getContents());
		    			for(String tool : listTool) shopTool += tool + " , ";
		    		}
		    		
		    	}
		    	d.setIndex(i);
		    	if(shopTool.length() > 0) shopTool = shopTool.substring(0, (shopTool.length()-3));
	    		System.out.println("Index : " + i + "-> Shop tool : " + shopTool);
	    		d.setShopTool(shopTool);
	    		WriteDataToExcel();
		    	
			    listDatas.add(d);
			    
			    if(listDatas.size() == 100) WriteDataToExcel();
			    
		    }
		    
		    if(listDatas.size() > 0) WriteDataToExcel();
		 
		    w.close();
		    
		} catch (IOException e) {
			e.printStackTrace();
		
		} catch (BiffException e) {

			e.printStackTrace();
			
		}
	}
}

