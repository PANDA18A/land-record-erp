-- ===========================================
-- LAND RECORD ERP DATABASE SCHEMA
-- Version : 1.0
-- Author  : PANDA18A
-- ===========================================


/*==========================================================
  MASTER TABLE : APPLICANT
==========================================================*/

CREATE TABLE applicant (
    applicant_id BIGSERIAL PRIMARY KEY,
    aadhaar_number VARCHAR(12) UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    mobile_number VARCHAR(10),
    email VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);



/*==========================================================
  TRANSACTION TABLE : APPLICATION
==========================================================*/

CREATE TABLE application (
    application_id BIGSERIAL PRIMARY KEY,
    applicant_id BIGINT NOT NULL,
    application_type VARCHAR(50) NOT NULL,
    application_date DATE NOT NULL DEFAULT CURRENT_DATE,

    status VARCHAR(30) NOT NULL DEFAULT 'PENDING'
        CHECK (
            status IN (
                'PENDING',
                'UNDER_VERIFICATION',
                'APPROVED',
                'REJECTED'
            )
        ),

    remarks TEXT,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_applicant
        FOREIGN KEY (applicant_id)
        REFERENCES applicant(applicant_id)
        ON DELETE RESTRICT
);



/*==========================================================
  MASTER TABLE : PLOT
==========================================================*/

CREATE TABLE plot (
    plot_id BIGSERIAL PRIMARY KEY,
    plot_number VARCHAR(50) NOT NULL,
    mouza VARCHAR(100) NOT NULL,
    jl_number VARCHAR(20) NOT NULL,
    area_decimal NUMERIC(10,2) NOT NULL,
    land_class VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_plot UNIQUE (plot_number, mouza)
);




/*==========================================================
  MASTER TABLE : OWNER
==========================================================*/
CREATE TABLE owner (
    owner_id BIGSERIAL PRIMARY KEY,

    full_name VARCHAR(100) NOT NULL,

    father_or_spouse_name VARCHAR(100),

    aadhaar_number VARCHAR(12) UNIQUE,

    mobile_number VARCHAR(10)
        CHECK (mobile_number ~ '^[0-9]{10}$'),

    email VARCHAR(100),

    owner_status VARCHAR(20)
        NOT NULL DEFAULT 'ACTIVE'
        CHECK (owner_status IN ('ACTIVE', 'INACTIVE')),

    created_at TIMESTAMP WITH TIME ZONE
        DEFAULT CURRENT_TIMESTAMP
);




/*==========================================================
  RELATIONSHIP TABLE : OWNERSHIP
==========================================================*/

CREATE TABLE ownership (

    ownership_id BIGSERIAL PRIMARY KEY,

    -- Relationship
    plot_id BIGINT NOT NULL,
    owner_id BIGINT NOT NULL,
    application_id BIGINT,

    -- Legal Share (Source of Truth)
    share_numerator NUMERIC(12,0) NOT NULL,
    share_denominator NUMERIC(12,0) NOT NULL,

    -- Derived Values
    share_percentage NUMERIC(8,4) NOT NULL,
    share_area NUMERIC(12,4) NOT NULL,

    -- Legal Source
    ownership_source VARCHAR(30) NOT NULL
        CHECK (
            ownership_source IN (
                'SALE',
                'GIFT',
                'INHERITANCE',
                'PARTITION',
                'COURT_ORDER',
                'LEASE',
                'GOVERNMENT_ACQUISITION',
                'OTHER'
            )
        ),

    -- Ownership Timeline
    effective_from DATE NOT NULL,
    effective_to DATE,

    -- Record Status
    ownership_status VARCHAR(20)
        NOT NULL DEFAULT 'ACTIVE'
        CHECK (
            ownership_status IN (
                'ACTIVE',
                'TRANSFERRED',
                'HISTORICAL',
                'DISPUTED'
            )
        ),

    remarks TEXT,

    created_at TIMESTAMP WITH TIME ZONE
        DEFAULT CURRENT_TIMESTAMP,

    -- Foreign Keys
    CONSTRAINT fk_ownership_plot
        FOREIGN KEY (plot_id)
        REFERENCES plot(plot_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_ownership_owner
        FOREIGN KEY (owner_id)
        REFERENCES owner(owner_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_ownership_application
        FOREIGN KEY (application_id)
        REFERENCES application(application_id)
        ON DELETE SET NULL,

    -- Validation
    CONSTRAINT chk_share_fraction
        CHECK (
            share_numerator > 0
            AND share_denominator > 0
            AND share_numerator <= share_denominator
        ),

    CONSTRAINT chk_effective_dates
        CHECK (
            effective_to IS NULL
            OR effective_to >= effective_from
        )
);