def corregir
  ps = Prov.all
  ps.each do |p|
    p2 = p.provincia.split.join("_")
    p.provincia = p2
    p.save
  end

  cs = Canton.all
  cs.each do |c|
     c2 = c.canton.split.join("_")
     c.canton = c2
     c.save
  end

  ds = Distrito.all
  ds.each do |d|
    d2 = d.distrito.split.join("_")
    d.distrito = d2
    d.save
  end
end
