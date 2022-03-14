function WriteReferenceFile(Reference,Filename)

Cell2write = [Reference.Time num2cell(Reference.LOS_TI_N') num2cell(Reference.LOS_TI_S')];
Cell2write = [{'Time','LOS_TI_North','LOS_TI_South'}; Cell2write];
writecell(Cell2write ,Filename)

end



