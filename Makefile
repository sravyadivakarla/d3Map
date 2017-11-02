all: pop.json

clean:
	rm -rf -- pop.json build

.PHONY: all clean

build/gz_2010_us_050_00_20m.shp: build/gz_2010_us_050_00_20m.zip
	unzip -od $(dir $@) $<
	touch $@

build/gz_2010_us_050_00_20m.zip:
	mkdir -p $(dir $@)
	curl -o $@ http://www2.census.gov/geo/tiger/GENZ2010/$(notdir $@)

build/counties.json: build/gz_2010_us_050_00_20m.shp pop.csv
	node_modules/.bin/topojson \
		-o $@ \
		--id-property='STATE+COUNTY,Id2' \
		--external-properties='pop.csv' \
		--properties='profit=+total_pop,name= Geography,r1=+White,r2=+Black,r3=+AmericanIndian,r4=+Indian,r5=+Hawaiian,r6=+Chinese,r7=+Other,r8= +Filipino,r9=+Japanese,r10=+Korean,r11=+Vietnamese'\
		--projection='width = 960, height = 600, d3.geo.albersUsa() \
			.scale(1280) \
			.translate([width / 2, height / 2])' \
		--simplify=.5 \
		-- counties=$<

build/states.json: build/counties.json
	node_modules/.bin/topojson-merge \
		-o $@ \
		--in-object=counties \
		--out-object=states \
		--key='d.id.substring(0,2)' \
		-- $<

pop.json: build/states.json
	node_modules/.bin/topojson-merge \
		-o $@ \
		--in-object=states \
		--out-object=nation \
		-- $<
