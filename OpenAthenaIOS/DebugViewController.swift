//
//  DebugViewController.swift
//  OpenAthenaIOS
//  https://github.com/rdkgit/OpenAthenaIOS
//  https://openathena.com
//  Created by Bobby Krupczak on 2/3/23.
//

import Foundation
import UIKit

class DebugViewController: UIViewController, UIScrollViewDelegate {
    
    var app: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var textView: UITextView = UITextView()
    var stackView: UIStackView = UIStackView()
    var scrollView: UIScrollView = UIScrollView()
    var contentView: UIView = UIView()
    var vc: ViewController!
    var htmlString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "OpenAthena Debug"
        view.backgroundColor = .secondarySystemBackground
        //view.overrideUserInterfaceStyle = .light
        
        // build the view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = true // enabled lest text get clipped
        textView.font = .systemFont(ofSize: 16)
        textView.textColor = .label
        textView.backgroundColor = .secondarySystemBackground
        
        scrollView.frame = view.bounds
        scrollView.zoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.minimumZoomScale = 0.5
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isUserInteractionEnabled = true
        scrollView.backgroundColor = .secondarySystemBackground
        
        htmlString = "Debug information<br>"
        setTextViewText(htmlStr: htmlString)
        
        stackView.frame = scrollView.bounds
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 5
        
        stackView.addArrangedSubview(textView)
        contentView.addSubview(stackView)
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        
        // set constraints
        
        textView.heightAnchor.constraint(equalToConstant: 1.0*view.frame.size.height).isActive = true
        
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        debug()
        
    } //viewDidLoad
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
    
    private func debug()
    {
        self.htmlString = "<b>OpenAthena Debug Info alpha \(vc.getAppVersion()) build \(vc.getAppBuildNumber()!)</b><br>"
        
        self.htmlString += "Coordinate system \(app.settings.outputMode)<br>"
        self.htmlString += "Drone params date: \(vc.droneParams!.droneParamsDate ?? "unknown"))<br>"
        self.htmlString += "CCD data for \(vc.droneParams!.droneCCDParams.count) drones<br>"
        self.htmlString += "Use CCD Info: \(app.settings.useCCDInfo)<br>"
        self.htmlString += "EGM96 model loaded: \(EGM96Geoid.s_model_ok)<br>"
        self.htmlString += "Compass correction: \(app.settings.compassCorrection)<br>"
 
        // do I have an API key?
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            if dict["OpenTopographyApiKey"] as? String != nil {
                self.htmlString += "API key present<br>"
            }
            else {
                self.htmlString += "API key NOT present<br>"
            }
        }
        
        // dem cache info
        let demCache = DemCache()
        self.htmlString += "\(demCache.count()) elevation maps in cache<br>"
        self.htmlString += "\(demCache.totalStorage()) bytes in elevation maps cache<br>"

        if vc.dem != nil {
            self.htmlString += "<br><b>DEM:</b> \((vc.dem!.tiffURL!.lastPathComponent))<br>"
            self.htmlString += "Width:\(vc.dem!.getDemWidth()) Height:\(vc.dem!.getDemHeight())<br>"
            self.htmlString += "Rasters: W:\(vc.dem!.rasters!.width()) H:\(vc.dem!.rasters!.height())<br>"
            self.htmlString += "Rasters: Pixels:\(vc.dem!.rasters!.numPixels()) S/P:\(vc.dem!.rasters!.samplesPerPixel())<br>"
            self.htmlString += "Rasters: SizePixel:\(vc.dem!.rasters!.sizePixel()) bytes<br>"
            self.htmlString += "TiePoint: \(vc.dem!.directory!.modelTiepoint()!))<br>"
            self.htmlString += "Bounding box:<br>"
            self.htmlString += "Upper left ( \(vc.dem!.getMaxLatitude()),\(vc.dem!.getMinLongitude()) )<br>"
            self.htmlString += "Lower left ( \(vc.dem!.getMinLatitude()),\(vc.dem!.getMinLongitude()) )<br>"
            self.htmlString += "Upper right ( \(vc.dem!.getMaxLatitude()),\(vc.dem!.getMaxLongitude()) )<br>"
            self.htmlString += "Lower right ( \(vc.dem!.getMinLatitude()),\(vc.dem!.getMaxLongitude()) )<br>"
            
            var centerLat,centerLon : Double
            (centerLat,centerLon) = vc.dem!.getCenter()
            
            let urlStr = "https://maps.google.com/maps/search/?api=1&t=k&query=\(centerLat),\(centerLon)"
            self.htmlString += "<a href='\(urlStr)'>\(urlStr)</a><br>"
        }
        else {
            self.htmlString += "<br><b>DEM:</b> not loaded<br>"
        }
        
        if vc.theDroneImage != nil {
            self.htmlString += "<br><b>Drone Image:</b> \(vc.theDroneImage!.name ?? "No name")<br>"
            do {
                var lat = try self.vc.theDroneImage!.getLatitude()
                var lon = try self.vc.theDroneImage!.getLongitude()
                self.htmlString += "Latitude: \(lat)<br>"
                self.htmlString += "Longitude: \(lon)<br>"
                let urlStr = "https://maps.google.com/maps/search/?api=1&t=k&query=\(lat),\(lon)"
                self.htmlString += "<a href='\(urlStr)'>\(urlStr)</a><br>"
                try self.htmlString += "Make: \(vc.theDroneImage!.getCameraMake())<br>"
                try self.htmlString += "Model: \(vc.theDroneImage!.getCameraModel())<br>"
                self.htmlString += "Old Autel: \(vc.theDroneImage!.isOldAutel())<br>"
                                
                try self.htmlString += "Focal Length: \(vc.theDroneImage!.getFocalLength())<br>"
                try self.htmlString += "Focal Length in 35mm: \(vc.theDroneImage!.getFocalLengthIn35mm())<br>"
                                
                self.htmlString += "Date/Time UTC: \(vc.theDroneImage!.getDateTimeUTC())"
                self.htmlString += "<br>aux:Lens \(vc.theDroneImage!.metaData!["aux:Lens"] ?? "not present")<br>"
                                
                if let mdTemp = vc.theDroneImage!.metaData {
                    self.htmlString += "<br>MetaData: \(mdTemp)<br>"
                }
                else {
                    self.htmlString += "<br>MetaData: none<br>"
                }
                if let mdTemp = vc.theDroneImage!.rawMetaData {
                    self.htmlString += "<br>RawMetaData: \(mdTemp)<br>"
                }
                else {
                    self.htmlString += "<br>RawMetaData: none<br>"
                }
                // can't print xml strings in html strings in swift due to backslashes
                // and other special chars?
                //if vc.theDroneImage!.xmlStringCopy != nil {
                    //self.htmlString += "<br>Xmp/Xml: \(vc.theDroneImage!.xmlStringCopy)<br>"
                    //print("Debug: xmlStringCopy is \(vc.theDroneImage!.xmlStringCopy)")
                //}
                
                do {
                    try self.htmlString += "Software version: \(vc.theDroneImage!.getMetaDataValue(key: "drone-parrot:SoftwareVersion"))<br>"
                }
                catch { }
            }
            catch {
                print("Caught an error \(error)")
                self.htmlString += "Some meta data missing \(error)<br>"
                self.htmlString += "Another catch clause<br>"
            }
        } else {
            self.htmlString += "Image: not loaded<br>"
        }
        
        if vc.dem != nil && vc.theDroneImage != nil {
            do {
                let alt = try vc.theDroneImage!.getAltitude()
                let relAlt = try vc.theDroneImage!.getRelativeAltitude()
                let altFromRel = try vc.theDroneImage!.getAltitudeViaRelative(dem: vc.dem!)
                self.htmlString += "Altitude: \(alt)<br>"
                self.htmlString += "RelativeAlt: \(relAlt)<br>"
                self.htmlString += "AltFromRelative: \(altFromRel)<br>"
            }
            catch {
                self.htmlString += "Some altitude data missing<br>"
            }
        }
        
        // display the text finally
        setTextViewText(htmlStr: self.htmlString)
        
    }
        
    // take htmlString and encode it and set
    // it to our textView
    private func setTextViewText(htmlStr hString: String)
    {
        let data = Data(hString.utf8)
        let font = UIFont.systemFont(ofSize: CGFloat(app.settings.fontSize))
        
        if let attribString = try? NSMutableAttributedString(data: data,
                                                           options: [.documentType: NSAttributedString.DocumentType.html],
                                                           documentAttributes: nil) {
            attribString.addAttribute(NSAttributedString.Key.font,
                                      value: font, range: NSRange(location: 0,
                                      length: attribString.length))
            attribString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.label, range: NSMakeRange(0,attribString.length))
            self.textView.attributedText = attribString
        }
    }
} // DebugViewController
