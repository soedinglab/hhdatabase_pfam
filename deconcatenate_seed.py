#!/usr/bin/env python
"""
Created on Thu May  7 15:41:41 2015

@author: Sagar
"""

from optparse import OptionParser

def deconcatenate_seed_file(seed_file, folder):
    
    with open(seed_file) as seed:

        current_file = list()
        current_pfam = ""
        
        for line in seed:
            current_file.append(line)            
            
            if line.startswith("#=GF AC"):
                splitted_line = line.split("   ")                     
                current_pfam = splitted_line[-1]
                
            if line.startswith("//"):
                file_name = folder + current_pfam.strip() + ".sto"
                with open(file_name, 'w+') as fout:
                    for line in current_file:
                        fout.write(line)
                # make the next file
                current_file = list()
                
def check_folder_name(folder):
    
    if folder.endswith("/"):
        return folder
    else:
        return folder + "/"

def opt():
    # Initiate a OptionParser Class
    parser = OptionParser()
    # Call add_options to the parser
    parser.add_option("-i", dest="seed",
                      help="Seed file.", metavar="GLOB")
    parser.add_option("-o", dest="folder", 
                      help="Output folder where all Pfam files are written to.", metavar="FOLDER")
    return parser

def main():
    parser = opt()
    # parse the the parser object and save the data into options and args
    # opts contains all values received via command line
    # argv contains a list of all commited argument 
    (options, argv) = parser.parse_args()
    
    folder_name = check_folder_name(options.folder)
    deconcatenate_seed_file(options.seed, folder_name)
   
if __name__ == "__main__":
    main()
