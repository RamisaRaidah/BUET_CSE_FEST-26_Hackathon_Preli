CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


CREATE TABLE IF NOT EXISTS locations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL,
    city VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    min_temperature INTEGER NOT NULL,
    max_temperature INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS storage_units (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    location_id UUID NOT NULL,
    min_temperature INTEGER NOT NULL,
    max_temperature INTEGER NOT NULL,
    capacity INTEGER NOT NULL CHECK (capacity >= 0),
    CONSTRAINT fk_storage_location FOREIGN KEY (location_id) REFERENCES locations(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS routes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    from_location_id UUID NOT NULL,
    to_location_id UUID NOT NULL,
    capacity INTEGER NOT NULL CHECK (capacity >= 0), 
    min_shipment INTEGER NOT NULL DEFAULT 0,    
    CONSTRAINT fk_route_from FOREIGN KEY (from_location_id) REFERENCES locations(id) ON DELETE CASCADE,
    CONSTRAINT fk_route_to FOREIGN KEY (to_location_id) REFERENCES locations(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS demands (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    location_id UUID NOT NULL,
    product_id UUID NOT NULL,
    date DATE NOT NULL,
    min_quantity INTEGER NOT NULL DEFAULT 1,
    max_quantity INTEGER NOT NULL,
    CONSTRAINT fk_demand_location FOREIGN KEY (location_id) REFERENCES locations(id) ON DELETE CASCADE,
    CONSTRAINT fk_demand_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);